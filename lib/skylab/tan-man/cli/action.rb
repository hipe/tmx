module Skylab::TanMan

  class CLI::Action
    # forward-declaration for this class-as-namespace #pattern [#sl-109]
  end

  module CLI::Action::ModuleMethods

    include Headless::NLP::EN::API_Action_Inflection_Hack

    include Headless::CLI::Action::ModuleMethods

    include Core::Action::ModuleMethods

                                               # this will have problems
                                               # we simply want to have a
                                               # box module while a the same
    def normalized_action_name                 # time not have one [#hl-075]
      @normalized_action_name ||= begin
        anchor_mod = actions_anchor_module
        anchor_name = anchor_mod.name
        0 == name.index( anchor_name ) or fail 'sanity'
        significant = name[ anchor_name.length + 2 .. -1 ]
        mod = anchor_mod
        a = significant.split '::'
        o = []
        use = true
        while x = a.shift
          mod = mod.const_get x, false
          if use
            o.push Autoloader::FUN.methodize[ x ]
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

    ACTIONS_ANCHOR_MODULE = -> { CLI::Actions }
    # the above is our "root" box module, for reflection (e.g. local_normal_name)

    event_factory CLI::Event::Factory

    empty_array = [ ].freeze

    define_singleton_method :desc do |*a| # compare to [#hl-033]
      if a.length.zero?  # (awful compat for bleeding, don't float this up)
        # (the right way dictates that we need an instance & runtime for this)
        ( new nil ).send( :desc_lines ) or empty_array
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
        fail 'wat'  # #todo
        res = nil
      end
      res
    end

    alias_method :help, :tan_man_help_adapter

    def render_invite_line inner_string, z=nil
      "try #{ kbd inner_string } for help#{ " #{ z }" if z }"
      # this is just symbolic - we wear `try` as a badge of shame
    end

    def resolve argv  # just blood
      @do_hack_normalize_callable = true
      res, meth, args = invoke argv
      if res
        [ meth, args ]
      end # always result in nil on failure - h.l took care of it
    end # with:
    def normalize_callable x  # hack parent to break out of its invoke loop early
      res = nil
      if @do_hack_normalize_callable
        res = [ super ]
      else
        res = super
      end
      res
    end

  private

    def initialize request_client
      @do_hack_normalize_callable = nil
      @param_h = { }

      init_headless_sub_client request_client

      # if an emitter emits and no listener is there to hear it, does it make
      # a sound? certainly not.

      on_call_to_action do |e|
        msg = TanMan::Services::
          Template[ e.template, action: act( e.action_class ) ]
        emit :help, msg  # if something else is listening to *this* ..
        nil
      end

      on_no_config_dir do |e|     # common to actions, but doesn't have
        e.touch!                  # to be here.
        msg = "couldn't find #{ e.dirname } in this or any parent #{
          }directory: #{ escape_path e.from }"
        error msg
        emit :call_to_action, action_class: CLI::Actions::Init,
                template: 'use {{action}} to create it'
      end

      on_info do |e|
        if ! e.is_inflected_with_action_name
          e.message = inflect_action_name e
          e.is_inflected_with_action_name = true
        end
      end

      on_error do |e|
        if ! e.is_inflected_with_failure_reason
          e.message = inflect_failure_reason e
          e.is_inflected_with_failure_reason = true
        end
      end

       on_all do |e|
        if ! e.touched?
          # we are re-emitting to parent the event #todo is this ok?
          request_client.send :emit,  e
        end
        nil
      end

    end

    def act action_class
      kbd( full_invocation_parts( action_class ).join ' ' )
    end
    #
    def full_invocation_parts cls
      [ program_name, * cls.normalized_action_name ]
    end

    def api_invoke *args          # [normalized acton name] [param_h]
      args.last.respond_to? :each_pair and any_param_h = args.pop
      norm_act_name = if args.last.respond_to? :each_index
        args.pop
      else
        normalized_action_name
      end
      @last_api_action_name_a = norm_act_name
      args.length.zero? or raise ::ArgumentError,
        "[normalized acton name] [param_h]"

      services.api.invoke norm_act_name, any_param_h, self, -> o do
        o.on_all { |e| emit e }  # do NOT change this to method(..) .. arity!
        # o.on_all( & method( :emit ) )
      end
    end

    def default_action # #compat-headless
      :process
    end

    def program_name # #compat-bleeding (tracked as [#hl-034])
      normalized_invocation_string
    end

    def program_name_hack
      # expect this to break around [#022] because bleeding thinks of
      # 'program name' as being the full path, but is broken for deep
      # graphs. or not
      program_name.split( ' ' ).first  # #ick
    end

    def inflect_action_name e
      msg, redress_p = undress e.message
      redress_p[ "#{ get_succeeded_a * ' ' }: #{ msg }" ]
    end

    def undress s
      if 2 < s.length and (( a = A_A__.detect do |l, r|
        l == s[ 0 ] and r == s[ -1 ]
      end ))
        l, r = a
        [ s[ 1 .. -2 ], -> s_ { "#{ l }#{ s_ }#{ r }" } ]
      else
        [ s, MetaHell::IDENTITY_ ]
      end
    end
    #
    A_A__ = [ %w( ( ) ) ]

    def inflect_failure_reason e
      "#{ get_failed_a * ' ' } - #{ e.message }"
    end

    def get_succeeded_a
      self.class.assemble_succeeded_a get_part_a
    end

    def get_failed_a
      self.class.assemble_failed_a get_part_a
    end

    def get_part_a
      y = [ ] ; x = program_name_hack and y << x
      len = (( name_a = self.class.normalized_action_name )).length
      if 0 < len
        y << get_bound_pos( :verb )
        if 1 < len
          y[ 1, 0 ] = [ get_bound_pos( :noun ) ]
          if 2 < len
            y[ 1, 0 ] = name_a[ 0 .. -3 ]  # adjectives
          end
        end
      end
      y
    end

    def get_bound_pos i
      lex_ = (( inf = self.class.inflection )).lexemes[ i ]
      lex = lex_.determine_pos_for self
      lex.bind_to_exponent inf.inflect[ i ]
    end

    def self.assemble_succeeded_a a
      y = [ ]
      if a.length.nonzero?
        y << 'while'
        (( w = Writer__.new y, a )).write_any_subject_noun_phrase
        w.write_any_passed_progressive_verb or y << 'was processing request'
        w.write_any_adjectives ; w.write_any_object_noun
      end
      y
    end

    def self.assemble_failed_a a
      y = [ ]
      if a.length.nonzero?
        (( w = Writer__.new y, a )).write_any_subject_noun_phrase
        w.prefix_any_verb( 'failed to' ) or y << 'failed'
        w.write_any_adjectives ; w.write_any_object_noun
      end
      y
    end

    class Writer__
      def initialize y, a
        @y = y ; @a = a ; @len = a.length
      end
      def write_any_subject_noun_phrase
        if 0 < @len
          @y << @a[ 0 ]
          if has_many_adjectives
            @y.concat @a[ 1 .. -3 ].reverse
          end
          true
        end
      end
      def write_any_passed_progressive_verb
        if (( v = any_bound_verb ))
          @y << "was #{ v.lexeme.progressive }" ; true
        end
      end
      def prefix_any_verb x
        if (( v = any_bound_verb ))
          @y << "#{ x } #{ v.lexeme.lemma }" ; true
        end
      end
    private
      def any_bound_verb
        if 1 < @len
          x = @a[ -1 ]
          if x.respond_to? :ascii_only?
            x = Headless::NLP::EN::POS::Verb[ x ].bind_to_exponent :lemma
          end
          x
        end
      end
    public
      def write_any_adjectives
        if 3 < @len and ! has_many_adjectives
          a = @a[ 1 .. -3 ]
          @y.concat a ; true
        end
      end
      def has_many_adjectives
        5 < @len
      end ; private :has_many_adjectives
      def write_any_object_noun
        if 2 < @len
          x = @a[ -2 ]
          if x.respond_to? :ascii_only?
            x = Headless::NLP::EN::POS::Noun[ x ].bind_to_exponent :singular
          end
          @y << x.string ; true
        end
      end
    end
  end
end
