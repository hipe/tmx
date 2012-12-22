module Skylab::TanMan

  class CLI::Action
    # forward-declaration for this class-as-namespace #pattern [#sl-109]
  end


  module CLI::Action::ModuleMethods
    include Headless::NLP::EN::API_Action_Inflection_Hack
    include Headless::CLI::Action::ModuleMethods
    include Core::Action::ModuleMethods


    def normalized_action_name                 # this will have problems
      @normalized_action_name ||= begin        # we simply want to have a box
        anchor = self::ANCHOR_MODULE.name      # module while at the same time
        0 == name.index( anchor ) or fail 'sanity'  # not have one
        significant = name[ anchor.length + 2 .. -1 ]
        mod = self::ANCHOR_MODULE
        a = significant.split '::'
        o = []
        use = true
        while x = a.shift
          mod = mod.const_get x, false
          if use
            o.push Autoloader::Inflection::FUN.methodify[ x ]
          else
            use = true
          end
          if mod.respond_to? :action_box_module  # #icky-reflection
            use = false
          end
        end
        o
      end
    end

    def option_parser &block
      ( @option_parser_blocks ||= [ ] ).push block
      nil
    end

    attr_reader :option_parser_blocks
  end


  module CLI::Action::InstanceMethods
    include Headless::CLI::Action::InstanceMethods
    include Core::Action::InstanceMethods

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      a = self.class.option_parser_blocks
      if a
        a.each do |b|
          instance_exec o, &b
        end
      else
        help_option o
      end
      o
    end
  end


  class CLI::Action
    extend CLI::Action::ModuleMethods
    include CLI::Action::InstanceMethods

    ANCHOR_MODULE = CLI::Actions  # We state what our box module is for
                                  # reflection (e.g. to get normalized name)

    def self.desc *a              # compare to [#hl-033]
      if a.empty? # (awful compat for bleeding, don't float this up)
        if ( @desc_lines ||= nil )
          @desc_lines
        else
          [ ].freeze
        end
      else
        super(* a )               # up to headless
      end
    end

    def self.unbound_invocation_method # #compat-bleeding
      instance_method default_action
    end

    # --*--

    alias_method :tan_man_original_help, :help

    def tan_man_help_adapter *a # #compat-bleeding - nothing of value here, just blood and noise
      res = false
      begin
        case a.length
        when 0
          res = tan_man_original_help
        when 1                    # this is so dodgy, but as it stands the
          if ::Hash === a.first   # legacy library emits only a limited set of
            case a.first.reduce( [ ] ) { |m, x| m.concat x ; m } # option states
            when [:full, true]
              help_screen
              res = true # just for fun, continue screening other option things
            when [:invite_only, true]
              emit :help, invite_line
              res = true
            end
          end
        end
      end while nil
      if false == res
        $stderr.puts "WAT: #{ o.inspect }"
        res = nil
      end
      res
    end

    alias_method :help, :tan_man_help_adapter

    def invite_line               # #compat-bleeding #compat-headless
    # (this is to get the tests to pass but note we should not in the future
    # assume that the terminal action does not take a meaningful `-h` opt.)
    # #todo
     "try #{ kbd "#{ request_runtime.send :normalized_invocation_string }#{
        } #{ normalized_local_action_name } -h" } for help"
    end


    proc_that_looks_like_bound_method = ::Struct.new :receiver, :name

    define_method :resolve do |argv|
                                  # what we have here is an attempt at making|
                                  # #compat-bleeding #compat-headless (!!)
      res = nil                   # compare to hl:cli:action:im#invoke
      begin                       # which it comes annoyingly close to
        @argv = argv
        @queue ||= []
        res = parse_opts( argv ) or break
        queue.push( default_action ) if queue.empty?
        execute = -> callable do  # do this for all but the last callable
          if callable.respond_to? :call  # in the queue: process it as normal
            res = callable.call   # (all of this is ridiculous and should be
          else                    # killed with fire, but is necessary during
            res = parse_argv_for( callable ) or break # jawbreak)
            res = send( callable, *res ) or break
          end
          nil
        end
        prepare = -> callable do  # do this for the last callable in the queue:
          if callable.respond_to? :call # something different:
            res = [               # we've got to follow what looks like
              ( proc_that_looks_like_bound_method.new callable, :call ),
              []                  # ( no args - you get NOTHING )
            ]                     # this tail-call recursion nonsense
          else
            res = parse_argv_for( callable ) or break
            res = [ method( callable ), res ]
          end
          # result looks like : [ (receiver, name), args ] ( a bound method )
          nil
        end
        while queue.length > 1    # (so, new way was queue, old way was tail-
          execute[ queue.shift ]  # call.  we run down the queue until the last
          res or break            # callble, then we pass that.)
        end
        res or break
        queue.length == 1 or fail "sanity"
        prepare[ queue.last ]
      end while nil
      res
    end

  protected

    # ---------------- jawbreak blood begin --------------------

    def initialize request_client
      self.param_h = { }

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
        if ! e.inflected_with_action_name
          e.message = inflect_action_name e
          e.inflected_with_action_name = true
        end
      end

      on_error do |e|
        if ! e.inflected_with_failure_reason
          e.message = inflect_failure_reason e
          e.inflected_with_failure_reason = true
        end
      end

       on_all do |e|
        # $stderr.puts "OK: #{ [e.type, e.message].inspect }"
        if ! e.touched?
          # we are re-emitting to parent the event #todo is this ok?
          request_client.send :emit,  e
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
      :process
    end

    def full_invocation_parts klass=self.class
      [program_name_hack, * klass.normalized_action_name]
    end

    def full_invocation_string klass=self.class
      full_invocation_parts( klass ).join ' '
    end

    def inflect_action_name e
      inflection = self.class.inflection
      prepositional_phrase = [ 'while' ]                             # "while"
      progressive = inflection.stems.verb.progressive
      subject = [ ]
      verb = [ progressive ]                                        # "adding"
      object = [ ]
      a = full_invocation_parts[ 0 .. -2 ] # the last item is handled by above.
      if a.length.nonzero?   # ( we should at least have the program_name )
        subject.push a.shift                                        # "tan-man"
        verb.unshift 'was'                                       # "was adding"
      end
      if a.length.nonzero?
        # target_class = self.class::ANCHOR_MODULE.const_fetch( a )
        a.pop # we used many elements in the line above, but we pop only 1 here
        subject.concat a # you could just as soon go object
        a.clear
        object.push inflection.inflected.noun
      end
      # "#{ full_invocation_parts.join ' ' }: #{ e }"
      pp = [ *prepositional_phrase, *subject, *verb, *object ].join ' '
      msg = e.message
      if '(' == msg[0]
        "(#{ pp }: #{ msg[1..-1] }"
      else
        "#{ pp }: #{ e.message }"
      end
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
      parts = full_invocation_parts
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
