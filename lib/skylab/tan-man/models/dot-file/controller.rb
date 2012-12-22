module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new  :dry_run,
                                                    :pathname,
                                                    :statement,
                                                    :verbose

    include Core::SubClient::InstanceMethods

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
                                dry_run: dry_run,
                              statement: statement,
                                verbose: verbose
      res
    end


  # --*-- the below are public but are for sub-clients only --*--

    def graph_noun
      "#{ escape_path pathname }"
    end

    def meanings
      @meanings ||= Models::DotFile::Meaning::Collection.new self
    end

    def set_meaning agent, target, create, dry_run, verbose,     # contrast
                                    error, success, neutral      # this way..
      meanings.set agent, target, create, dry_run, verbose,
                                   error, success, neutral
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

    def unset_meaning *a                                         # ..with this.
      meanings.unset(* a)
    end

    nl_rx = /\n/ # meh
    num_lines = -> str do
      scn = TanMan::Services::StringScanner.new str
      num = 0
      num += 1 while scn.skip_until( nl_rx )
      num += 1 unless scn.eos?
      num
    end

    define_method :write do |dry_run, force, verbose|
      bytes = nil
      begin
        next_string = sexp.unparse
        if ! pathname.exist?
          error "strange - #{graph_noun} didn't previously exist - won't write"
          break # or just raise
        end
        pathname.exist? or fail 'sanity'
        prev_string = pathname.read
        if prev_string == next_string
          info "(no changes in #{ graph_noun } - nothing to save.)"
          break
        end
        num_a = num_lines[ prev_string ]
        num_b = num_lines[ next_string ]
        if num_b < num_a && ! force
          error "ok to reduce number of lines in #{
            }#{ escape_path pathname } from #{ num_a } to #{ num_b }? #{
            }If so, use #{ par :force }."
          break # IMPORTANT!
        end
        bytes = write_commit next_string, dry_run, verbose
        break if ! bytes
        info "wrote #{ escape_path pathname } (#{ bytes } bytes)"
      end while nil
      bytes
    end

  protected

    def write_commit string, dry_run, verbose
      res = nil
      begin
        temp = services.tmpdir.tmpdir.join 'next.dot'
        bytes = nil
        temp.open( 'w' ) { |fh| bytes = fh.write string }
        diff = services.diff.diff pathname, temp, nil,
          -> e { error e }, -> i { info gsub_path_hack( i ) }
        break( res = diff ) if ! diff
        a = []
        nerk = -> x, str do
          break if x == 0
          a.push "#{ x } line#{ s x } #{ s x, :was } #{ str }"
        end
        nerk[ diff.num_lines_removed, 'removed' ]
        nerk[ diff.num_lines_added,   'added'   ]
        was_empty = a.empty?
        no_change = ( 0 == diff.num_lines_added && 0 == diff.num_lines_removed )
        if no_change
          a.push "no lines added or removed!"
        end
        info a.join( ', ' )
        break if no_change
        fu = Headless::IO::FU.new -> msg do
          info gsub_path_hack( msg )
        end
        fu.mv temp, pathname, noop: dry_run
        bytes
      end while nil
      res
    end
  end
end
