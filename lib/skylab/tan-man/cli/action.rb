module Skylab::TanMan

  class CLI::Action
    extend Bleeding::Action # this infects us with a metric fuckton
      # of bloat and pasta that we don't want from bleeding -- one day we will
      # do po -> hl [#018] -- but for now we need porcelain like desc() that we
      # don't yet have in hl. (7 modules from bleeding, 2 from hl!) can't wait!

    extend Core::Action::ModuleMethods

    # include Headless::CLI::Action::InstanceMethods # let's see if this plays
      # nice with bleeding above - no. also what is our order, w/ re: to below

    include Core::Action::InstanceMethods

    ANCHOR_MODULE = CLI::Actions  # We state what our box module is for
                                  # reflection (e.g. to get normalized name)

  protected

    # ---------------- jawbreak blood begin --------------------

    def initialize request_client
      _sub_client_init! request_client

      # if an emitter emits and no listener is there to hear it, does it make
      # a sound? certainly not.

      on_no_config_dir do |e|     # common to actions, but doesn't have
        e.touch!                  # to be here.
        msg = "couldn't find #{ e.dirname } in this or any parent #{
          }directory: #{ e.from.pretty }"
        error msg
        info "(try #{ kbd( full_invocation_string CLI::Actions::Init ) } #{
          }to create it)"
      end

      on_info do |e|
        e.message = "#{ full_invocation_string }: #{ e.message}"
      end

      on_error do |e|
        e.message = inflect_failure_reason e
      end

      on_all do |e|
        # $stderr.puts "OK: #{ [e.type, e.message].inspect }"
        if ! e.touched?
          rc = self.request_client
          rc.emit e # we are re-emiting to our parent the modified event
        end
        nil
      end
    end

    # ---------------- jawbreak blood end --------------------

    def api_invoke params_h
      service.api.invoke normalized_action_name, params_h, self, -> o do
        o.on_all { |event| emit event }
      end
    end

    def full_invocation_parts klass
      [program_name_hack, * klass.normalized_action_name]
    end

    def full_invocation_string klass=self.class
      full_invocation_parts( klass ).join ' '
    end

    # ""                          -> ""
    # "tanman"                    -> "tanman failed"
    # "tanman/add"                -> "tanman failed to add"
    # "tanman/remote/add"         -> "tanman failed to add remote"
    # "tanman/graph/example/set"  -> "tanman graph failed to set example"
    # "tanman/internationalization/language/preference/set" -> [...]
    #
    # this looks like [#hl-018] as seen in po

    sentence = -> a do
      o = []
      begin
        a.empty? and break
        a = a.dup
        o.push a.shift
        if a.empty?
          o.push 'failed'
          break
        end
        o.concat a[0 .. -3].reverse # crazy , frivolous fun
        a[0 .. -3] = []
        o.concat [ 'failed', 'to', *a.reverse ]
      end while nil
      o
    end

    define_singleton_method( :failed_sentence ) { sentence } # for testing! meh

    define_method :inflect_failure_reason do |e|
      parts = full_invocation_parts self.class
      words = sentence[ parts ]
      "#{ words.join ' '} - #{ e.message }"
    end

    def program_name_hack
      # expect this to break around [#022] because bleeding thinks of
      # 'program name' as being the full path, but is broken for deep
      # graphs. or not
      program_name =  self.program_name.split(' ').first # #ick
    end
  end
end
