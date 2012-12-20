module Skylab::TanMan

  class CLI::Action
    extend Headless::CLI::Action::ModuleMethods
    extend Core::Action::ModuleMethods

    include Headless::CLI::Action::InstanceMethods
    include Core::Action::InstanceMethods

    ANCHOR_MODULE = CLI::Actions  # We state what our box module is for
                                  # reflection (e.g. to get normalized name)

    def self.desc *a # up to [#hl-033] when ready
      if a.empty? # (awful compat for bleeding, don't float this up)
        if( @desc_lines ||= nil )
          @desc_lines
        else
          [ ].freeze
        end
      else
        ( @desc_lines ||= [ ] ).concat a
        nil
      end
    end

    def self.unbound_invocation_method # #compat-bleeding
      instance_method :invoke
    end

    # --*--

    alias_method :tan_man_original_help, :help

    def help o # #bleeding-compat. there is nothing of value here,
      res = false                 # only blood and noise
      begin
        1 == o.length or break
        case [o.keys.first, o[o.keys.first]]
        when [:full, true]
          help_screen
          res = true # just for fun, continue screening other option things
        when [:invite_only, true]
          emit :help, invite_line
          res = true
        end
      end while nil
      if false == res
        $stderr.puts "WAT: #{ o.inspect }"
        res = nil
      end
      res
    end

    def invite_line               # #compat-bleeding #compat-headless
    # (this is to get the tests to pass but note we should not in the future
    # assume that the terminal action does not take a meaningful `-h` opt.)
     "try #{ kbd "#{ request_runtime.send :normalized_invocation_string }#{
        } #{ normalized_local_action_name } -h" } for help"
    end

    def resolve argv              # what we have here is an attempt at making
                                  # #compat-bleeding #compat-headless (!!)
      res = nil                   # compare to hl:cli:action:im#invoke
      begin
        @argv = argv
        self.param_h ||= { }
        @queue ||= []
        res = parse_opts( argv ) or break
        queue.push( default_action ) if queue.empty?
        while queue.length > 1
          meth = queue.shift
          res = parse_argv_for( meth ) or break
          res = send( meth, *res ) or break
        end
        res or break
        meth = queue.shift
        res = parse_argv_for( meth ) or break
        res = [ method( meth ), res ]
      end while nil
      res
    end

  protected

    # ---------------- jawbreak blood begin --------------------

    def initialize request_client
      _headless_sub_client_init! request_client

      # if an emitter emits and no listener is there to hear it, does it make
      # a sound? certainly not.

      on_no_config_dir do |e|     # common to actions, but doesn't have
        e.touch!                  # to be here.
        msg = "couldn't find #{ e.dirname } in this or any parent #{
          }directory: #{ escape_path e.from }"
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

    def api_invoke *args          # [normalized acton name] [params_h]
      if ::Hash === args.last
        params_h = args.pop       # else nil ok for these
      end
      if ::Array === args.last
        normalized_action_name = args.pop
      else
        normalized_action_name = self.normalized_action_name
      end
      if args.any?
        raise ::ArgumentError.exception "[normalized acton name] [params_h]"
      end

      services.api.invoke normalized_action_name, params_h, self, -> o do
        o.on_all { |event| emit event }
      end
    end

    def default_action # #compat-headless
      :invoke
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
    # this looks like [#hl-018], Headless::NLP::EN::API_Action_Inflection_Hack

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

    def program_name # #compat-bleeding (tracked as [#hl-034])
      normalized_invocation_string
    end

    def program_name_hack
      # expect this to break around [#022] because bleeding thinks of
      # 'program name' as being the full path, but is broken for deep
      # graphs. or not
      program_name =  self.program_name.split(' ').first # #ick
    end
  end
end
