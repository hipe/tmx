module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new  :pathname,
                                                    :statement,
                                                    :verbose

    include Core::SubClient::InstanceMethods # the whole shebang is oldschoold

    extend Headless::Parameter::Controller::StructAdapter # just the members

    include Models::DotFile::Parser::InstanceMethods

    def check
      sexp = self.sexp
      if sexp
        if verbose
          # this is strictly a debugging thing expected to be used from the
          # command line.  using the `infostream` (which here in the api
          # is a facade to an event emitter) is really icky and overkill here,
          # hence we just use $stderr directly :/
          TanMan::Services::PP.pp sexp, $stderr
          s = ::Pathname.new( __FILE__ ).relative_path_from TanMan.dir_pathname
          info "(from #{ s })"
        else
          info "#{ escape_path pathname } looks good : #{ sexp.class }"
        end
      else
        info "#{ escape_path pathname } didn't parse (?) : #{ sexp.inspect }"
      end
      true
    end

    constantize = ::Skylab::Autoloader::Inflection::FUN.constantize

    define_method :execute do     # execute a statement
      rule = statement.class.rule.to_s
      rule_stem = rule.match(/_statement\z/).pre_match
      action_class = Models::DotFile::Actions.const_fetch rule_stem
      o = action_class.new self
      res = o.invoke dotfile_controller: self,
                              statement: statement
      res
    end


  # --*-- the below are public but are for sub-clients only --*--

    def graph_noun
      "#{ escape_path pathname }"
    end

    def sexp
      services.tree.fetch pathname do |k, svc|
        tree = parse_file pathname
        if tree
          svc.set! k, tree
        end
        tree
      end
    end

  protected

    def initialize request_client
      _sub_client_init! request_client
    end
  end
end
