module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new :pathname, :statement
    include Core::SubClient::InstanceMethods # the whole shebang is oldschoold

    extend Headless::Parameter::Controller::StructAdapter # just the members

    include Models::DotFile::Parser::InstanceMethods

    def check
      result = parse_file pathname
      info "OK in dot-file/controller.rb we got something .."
      require 'pp' ; ::PP.pp result
      true
    end

    constantize = ::Skylab::Autoloader::Inflection::FUN.constantize

    define_method :execute do     # execute a statement
      rule = statement.class.rule.to_s
      foo = rule.match(/_statement\z/).pre_match
      const = constantize[ foo ]
      $stderr.puts "HELLS YEAH YOU ARE READY FOR BOXXY"
      exit
      action_class = Models::DotFile::Actions.const_fetch const # etc ..
      o = action_class.new request_client
      result = o.invoke digraph: self, statement: statment
      result
    end

  protected

    def initialize request_client, pathname = nil
      _sub_client_init! request_client
      self.pathname = pathname
    end
  end
end
