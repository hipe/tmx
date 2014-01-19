module Skylab::MetaHell

  module FUN::Parse::Curry  # read [#011] the fun parse curry narrative

    def self.[] * input_a
      Parse_.new( input_a ).shell
    end

    Parse = FUN::Parse

    class Shell_  # #storypoint-55

      def initialize parse
        @parse = parse
      end

      def [] *a
        p = @parse.dupe
        p.call_notify a
      end

      alias_method :call, :[]

      def parse_argv argv
        value = get_value
        did_parse, _is_spent = @parse.dupe.
          call_notify [ value, argv || EMPTY_A_ ]
        value if did_parse
      end

      def get_value
        Puff_value_class_[ @parse.some_constantspace_mod, @parse ].new
      end
      #
      Puff_value_class_ = FUN::Puff_constant_.curry[ false, -> parse do
        Parse::Field_::Values_.new parse._field_a
      end, :Parse_Value_ ]

      def curry
        -> *a do
          p = @parse.dupe
          p.curry_notify a
        end
      end

      def get_parse
        @parse.dupe
      end

      def syntax_string
        @parse.render_syntax_string
      end

      def lookup_field i
        @parse.lookup_field_notify i
      end

      def _p
        @parse  # #shh - you can ruin everything
      end

      def _field_a
        @parse._field_a
      end
    end

    class Parse_
      def initialize input_a
        @abstract_field_list = @call_p = @constantspace_mod =
          @do_glob_extra_args = @exhaustion_p = @syntax = nil
        @state_mutex =
            MetaHell::Library_::Basic::Mutex::Write_Once.new :state_mutex
          # state encompasses input and output. various algorithms may handle
          # input and output together or separately, but we ensure that etc.
        absorb( * input_a )
      end

      # ~ :+[#056] typical base class implementation:
      def dupe
        otr = self.class.allocate
        otr.initialize_copy_MINE self
        otr
      end
      def initialize_copy_MINE otr
        init_copy( * otr.get_args_for_copy ) ; nil
      end
    protected
      def get_args_for_copy
        [ @abstract_field_list,
          @algorithm_p,
          @call_p,
          @constantspace_mod,
          @curry_queue_a,
          @do_glob_extra_args,
          @exhaustion_p,
          @state_mutex,
          @syntax ]
      end
    private
      def init_copy * x_a
        @abstract_field_list,
          @algorithm_p,
          @call_p,
          @constantspace_mod,
          cqa,
          @do_glob_extra_args,
          @exhaustion_p,
          sm,
          @syntax = x_a

        @curry_queue_a = ( cqa.dup if cqa )
        @field = nil
        @state_mutex = sm.dupe ; nil
      end
      # ~

    public
      def shell
        @shell ||= Shell_.new self
      end
      def call_notify a  # assume was already duped. will mutate self, a
        instance_exec( *a, & @call_p )  # result!
      end
      def curry_notify a  # assume was already duped. will mutate self, a
        op_box = field_box
        clear_last
        while a.length.nonzero?
          x = a.shift
          fld = op_box.fetch x do
            raise ::ArgumentError, "unrecognized element: #{ Parse::
              Strange_[ x ] }#{ any_context }#{
              }#{ Lev__[ op_box.get_names, x ] if x.respond_to? :id2name }"
          end
          set_last_x x
          remove_from_curry_queue x
          send fld.method_i, a
        end
        shell
      end
      #
      Lev__ = -> a, x do
        " - did you mean #{ Lev___[ a, x ] }?"
      end
      #
      Lev___ = -> a, x do
        MetaHell::Library_::Headless::NLP::EN::Levenshtein::
          Or_with_closest_n_items_to_item[ 3, a, x ]
      end
      def clear_last
        @prev_x = @last_x = nil
      end
      def set_last_x x
        @prev_x = @last_x
        @last_x = x
        nil
      end
      def any_context
        y = [ ]
        @prev_x and y << say_prev( @prev_x )
        @last_x and y << say_prev( @last_x )
        y.length.nonzero? and y * ', '
      end
      def say_prev x
        if x.respond_to? :id2name
          " after \"#{ x }\""
        else
          x.any_context
        end
      end
      def normal_token_proc_a
        @abstract_field_list.get_normal_token_proc_a
      end
      def normal_argv_proc_a
        @abstract_field_list.get_normal_argv_proc_a
      end
      def get_pool_proc_a
        @abstract_field_list.get_pool_proc_a
      end
      def exhaustion_notification argv, ai
        p = @exhaustion_p
        case p.arity
        when 0 ; p.call
        when 1
          v = argv.fetch ai
          e = Exhausted_[ -> do
            "unrecognized argument at index #{ ai } - #{ v.inspect }"
          end, ai, v, get_syntax_proc ]
          p[ e ]
        else
          p[ argv, ai ]
        end
        nil
      end
      Exhausted_ = ::Struct.new :message_proc, :index, :value, :syntax_proc
      def render_syntax_string
        get_syntax_proc.call
      end
      def lookup_field_notify predicate_i
        @abstract_field_list._field_a.reduce nil do |_, fld|
          fld.predicates.include?( predicate_i ) and break fld
        end
      end
      def _field_a  # #hacks-only
        @abstract_field_list._field_a
      end
      attr_reader :constantspace_mod
      def some_constantspace_mod
        constantspace_mod or raise "use `constantspace` to define a module"
      end
    private
      def set_abstract_field_list class_i, a  # #storypoint-215
        fields_being_added_notification
        @abstract_field_list = Abstract_Field_List_.new class_i, a
        nil
      end
      def fields_being_added_notification
        remove_from_curry_queue :token_matchers, :token_scanners,
          :argv_scanners
        nil
      end
      def absorb_along_curry_queue_and_execute *a
        absorb_along_curry_queue( *a )
        execute
      end
      def absorb_along_curry_queue *a
        cq = @curry_queue_a
        if cq.length < a.length
          @do_glob_extra_args or raise ::ArgumentError, say_too_many( cq, a )
          a[ cq.length - 1 .. -1 ] = [ a[ cq.length - 1 .. -1 ] ]
          # #storypoint-235
        end
        aa = [ ]
        a.length.times do
          aa << cq.shift << a.shift
        end
        absorb( *aa )
        nil
      end
      def say_too_many cq, a
        "too many arguments (#{ a.length } for #{ cq.length } #{
        }((#{ a.map( & :class ) }) for (#{ @curry_queue_a * ', ' }))"
      end
      def execute
        @state_mutex.is_held or fail "sanity - there is no e.g `parse_a` or #{
          }or `state_x_a` to pass to the algorithm"
        @algorithm_p[ self, @state_x ]
      end
      def remove_from_curry_queue * i_a  # [#bm-001]
        found = @curry_queue_a & i_a
        if found.length.nonzero?
          @curry_queue_a -= found
          curry_queue_changed_notification
          true
        end
        nil
      end
      def curry_queue_changed_notification
        standardize_call_p!
        nil
      end
      def standardize_call_p!
        @call_p = Standard_call_p_
        nil
      end
      Standard_call_p_ = -> *a do
        absorb_along_curry_queue_and_execute( *a )
      end
      def get_syntax_proc
        if @syntax
          -> do
            instance_exec( & @syntax.build_syntax_proc( @abstract_field_list ) )
          end
        else
          MetaHell::EMPTY_P_
        end
      end
    FUN::Fields_::From_.methods do  # (borrow one indent)
      def algorithm a
        @algorithm_p = a.fetch 0 ; a.shift
        nil
      end
      def exhaustion a
        x = a.fetch 0 ; a.shift
        @exhaustion_p = false == x ? Exhaustion_when_false_ : x
        nil
      end
      Exhaustion_when_false_ = -> argv, ai do  # #storypoint-290
        argv[ 0, ai ] = MetaHell::EMPTY_A_ ; nil
      end
      def uncurried_queue a
        @curry_queue_a = a.fetch 0 ; a.shift
        nil
      end
      def prepend_to_uncurried_queue a
        @curry_queue_a.unshift a.fetch 0 ; a.shift
        curry_queue_changed_notification
        nil
      end
      def append_to_uncurried_queue a
        @curry_queue_a.push a.fetch 0 ; a.shift
        curry_queue_changed_notification
        nil
      end
      def call a
        @call_p = a.fetch 0 ; a.shift
        nil
      end
      def glob_extra_args _
        @do_glob_extra_args = true
        nil
      end
      def token_matchers a
        set_abstract_field_list :Token_Matcher_, ( a.fetch 0 )
        a.shift
        nil
      end
      def token_scanners a
        set_abstract_field_list :Token_Scanner_, ( a.fetch 0 )
        a.shift
        nil
      end
      def argv_scanners a
        set_abstract_field_list :Argv_Scanner_, ( a.fetch 0 )
        a.shift
        nil
      end
      def pool_procs a
        set_abstract_field_list :Pool_Proc_, ( a.fetch 0 )
        a.shift
        nil
      end
      def argv a
        @state_mutex.hold :argv
        @state_x = a.fetch 0 ; a.shift
        nil
      end
      def state_x_a a
        @state_mutex.hold :state_x_a
        @state_x = a.fetch 0 ; a.shift
        nil
      end
      def syntax a
        did = nil
        @syntax ||= ( did = true and Syntax_.new )
        did or fail "you should probably deep dup these immutable syntaxes!"
        @syntax.absorb_notify a
        nil
      end
      def field a
        dflt = ( @default_field if instance_variable_defined? :@default_field )
        field = Resolve_field_[ a ]
        set_last_x field
        dflt and field.merge_defaults! dflt
        if field.looks_like_default?
          @default_field = field
        else
          ( @abstract_field_list ||= begin
            fields_being_added_notification
            Mutable_Concrete_Field_List_.new
          end ).add_field field
        end
      end
      Resolve_field_ = -> a do
        x = a.fetch 0  # DID NOT SHIFT YET
        if x.respond_to? :id2name
          field = Parse::Field_.new
          do_absorb = true
        elsif x.respond_to? :superclass
          field = x.new ; a.shift
          do_absorb = true
        else
          field = x ; a.shift
        end
        do_absorb and field.absorb_notify a
        field
      end
      def constantspace a
        @constantspace_mod = a.fetch 0 ; a.shift
        nil
      end
      end  # (pay one back)
    end

    class Syntax_
      def build_syntax_proc afl
        mk = @monikate_p
        -> do
          a = afl.reduce [ ] do |m, fld|
            m.concat instance_exec( & fld.get_monikers_proc )
          end
          mk[ a ]
        end
      end
    FUN::Fields_::From_.methods do
      def monikate a
        @monikate_p = a.fetch 0 ; a.shift
        nil
      end
    end
    end

    class Abstract_Field_List_  # externally immutable! shared.
      def initialize class_i, a
        ::Array.try_convert( a ) or raise "sanity - array? #{ a }"
        @class_i = class_i ; @surface_a = a
        @did_collapse = nil
      end
      def get_normal_token_proc_a
        @did_collapse or collapse!
        @deep_a.map( & :normal_token_proc )
      end
      def get_normal_argv_proc_a
        @did_collapse or collapse!
        @deep_a.map( & :normal_argv_proc )
      end
      def get_pool_proc_a
        @did_collapse or collapse!
        @deep_a.map( & :pool_proc )
      end
    private
      def collapse!
        clas = FUN::Parse::Curry.const_get @class_i, false
        @did_collapse = true
        @deep_a = @surface_a.map( & clas.method( :new ) ).freeze
        nil
      end
    end

    class Mutable_Concrete_Field_List_
      def initialize
        @field_a = [ ]
      end
      def add_field fld
        @field_a << fld
        nil
      end
      def get_normal_token_proc_a
        @field_a.map( & :normal_token_proc )
      end
      def get_pool_proc_a
        @field_a.map( & :pool_proc )
      end
      def reduce m, &b
        @field_a.reduce m, &b
      end
      def _field_a  # #hacks-only
        @field_a
      end
    end

    Token_Matcher_ = ::Struct.new :normal_token_proc
    class Token_Matcher_
      def initialize p
        super -> tok do
          [ true, tok ] if p[ tok ]
        end
      end
    end

    Normal_Scanner__ = ::Struct.new :_normal_proc
    class Normal_Scanner__
      def initialize p
        super -> tok do
          if ! (( x = p[ tok ] )).nil?
            [ true, x ]
          end
        end
      end
    end

    class Token_Scanner_ < Normal_Scanner__
      alias_method :normal_token_proc, :_normal_proc
    end

    class Argv_Scanner_ < Normal_Scanner__
      alias_method :normal_argv_proc, :_normal_proc
    end

    Pool_Proc_ = ::Struct.new :pool_proc
  end
end
