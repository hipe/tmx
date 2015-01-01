module Skylab::MetaHell

  module Parse::Curry_  # read [#011] the fun parse curry narrative

    def self.[] * input_a
      Parse__.new( input_a ).shell
    end

    class Shell__  # #storypoint-55

      def initialize parse
        @parse = parse
      end

      def [] *a
        @parse.dupe.call_notify a
      end

      alias_method :call, :[]

      def via_arglist a
        @parse.dupe.call_notify a
      end

      def parse_argv argv
        value = get_value
        did_parse, _is_spent = @parse.dupe.
          call_notify [ value, argv || EMPTY_A_ ]
        value if did_parse
      end

      def get_value
        Touch_value_class__[ @parse.some_constantspace_mod, @parse ].new
      end

      Touch_value_class__ = MetaHell_.touch_const.curry[
        false,  # do not inherit
        -> parse do
          Parse::Field::Values.new parse._field_a
        end,
        :Parse_Value_ ]

      def curry
        -> * x_a do
          @parse.dupe.shell_curried_with_iambic x_a
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

    class Parse__

      def initialize input_a

        @abstract_field_list = @call_p = @constantspace_mod =
          @default_field = @do_glob_extra_args = @exhaustion_p = @syntax = nil

        @state_mutex = MetaHell_.lib_.mutex_lib.write_once.new :state_mutex

          # state encompasses input and output. various algorithms may handle
          # input and output together or separately, but we ensure that etc.

        absrb_iambic_fully input_a ; nil
      end

      def dupe
        dup
      end

      def initialize_copy _otr_  # :+[#056] (ok)
        # copy-by-reference: @abstract_field_list, @algorithm_p, @call_p,
        #   @constantspace_mod, @do_glob_extra_args,
        #   @default_field, @exhaustion_p, @syntax

        # deep-copy:
        @curry_queue_a &&= @curry_queue_a.dup
        @state_mutex = @state_mutex.dupe

        # NOT copied at all: parse-state related ivars
        @d = @iambic_scan = @x_a = @x_a_length = nil
        @shell = nil  # otherwise you'll have the shell of the earlier parse!
      end

    public
      def shell
        @shell ||= Shell__.new self
      end
      def call_notify a  # assume was already duped. will mutate self
        instance_exec( *a, & @call_p )  # result!
      end
      def shell_curried_with_iambic x_a  # assume was already duped. will mutate self
        @d = 0 ; prepare_peaceful_parse_for_iambic x_a
        fld_box = field_box
        while @d < @x_a_length
          i = @x_a.fetch @d ; @d += 1
          fld = fld_box.fetch i do
            raise ::ArgumentError, say_extra( i )
          end
          remove_from_curry_queue i
          send fld.method_i
        end
        shell
      end
    private
      def say_extra x
        if x.respond_to? :id2name
          _did_you_mean = " - did you mean #{ say_lev x }?"
        end
        "unrecognized element: #{ MetaHell_.strange x }#{ any_context }"
      end

      def say_lev x
        MetaHell_.lib_.levenshtein.with(
          :item, x,
          :items, field_box.get_names,
          :closest_N_items, 3,
          :aggregation_proc, -> a { a * ' or ' } )
      end

      def any_context
        y = []
        1 < @d and y.push say_prev @x_a.fetch @d - 2
        0 < @d and y.push say_prev @x_a.fetch @d - 1
        y.length.nonzero? and y * ', '
      end
      def say_prev x
        if x.respond_to? :id2name
          " after \"#{ x }\""
        else
          x.any_context
        end
      end
    public
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
        @abstract_field_list = Abstract_Field_List__.new class_i, a
        nil
      end
      def fields_being_added_notification
        remove_from_curry_queue :token_matchers, :token_scanners,
          :argv_streams
        nil
      end
      def absorb_along_curry_queue_and_execute * a
        absrb_along_curry_queue_list a
        execute
      end
      def absrb_along_curry_queue_and_execute_list a
        absrb_along_curry_queue_list a
        execute
      end
      def absorb_along_curry_queue * a
        absrb_along_curry_queue_list a
      end
      def absrb_along_curry_queue_list a
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
        absrb_iambic_fully aa ; nil
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
        end ; nil
      end
      def curry_queue_changed_notification
        standardize_call_p! ; nil
      end
      def standardize_call_p!
        @call_p = STANDARD_CALL_P__ ; nil
      end
      STANDARD_CALL_P__ = -> *a do
        absrb_along_curry_queue_and_execute_list a
      end
      def get_syntax_proc
        if @syntax
          -> do
            instance_exec( & @syntax.build_syntax_proc( @abstract_field_list ) )
          end
        else
          EMPTY_P_
        end
      end

    MetaHell_::Fields::From.methods(
      :absorber, :absrb_iambic_fully,
      :globbing, :absorber, :with
    ) do  # #borrow-one-indent

      def algorithm
        @algorithm_p = iambic_property
      end
      def exhaustion
        x = iambic_property
        @exhaustion_p = false == x ? Exhaustion_when_false_ : x
      end
      Exhaustion_when_false_ = -> argv, ai do  # #storypoint-290
        argv[ 0, ai ] = EMPTY_A_
      end
      def uncurried_queue
        @curry_queue_a = iambic_property
      end
      def prepend_to_uncurried_queue
        @curry_queue_a.unshift iambic_property
        curry_queue_changed_notification
      end
      def append_to_uncurried_queue
        @curry_queue_a.push iambic_property
        curry_queue_changed_notification
      end
      def call
        @call_p = iambic_property
      end
      def glob_extra_args
        @do_glob_extra_args = true
      end
      def token_matchers
        set_abstract_field_list :Token_Matcher_, iambic_property
      end
      def token_scanners
        set_abstract_field_list :Token_Scanner_, iambic_property
      end
      def argv_streams
        set_abstract_field_list :Argv_Scanner_, iambic_property
      end
      def pool_procs
        set_abstract_field_list :Pool_Proc_, iambic_property
      end
      def argv
        @state_mutex.hold :argv
        @state_x = iambic_property
      end
      def state_x_a
        @state_mutex.hold :state_x_a
        @state_x = iambic_property
      end
      def syntax
        @syntax and fail "FIXME: deep dup these immutable syntaxes?"
        @syntax = Syntax__.new
        d = @syntax.d = @d
        @syntax.absorb_iambic_passively @x_a
        d_ = @syntax.d
        d == d_ and raise ::ArgumentError, "syntax needs argument"
        @d = d_
      end
      def field
        @d, field = Resolve_field__[ @d, @x_a ]
        @default_field and field.merge_defaults! @default_field
        if field.looks_like_default?
          @default_field = field
        else
          abstract_field_list.add_field field
        end
      end
      Resolve_field__ = -> d, x_a do
        x = x_a.fetch d
        if x.respond_to? :id2name
          field = Parse::Field_.new
          do_absorb = true
        elsif x.respond_to? :superclass
          field = x.new ; d += 1
          do_absorb = true
        else
          field = x ; d += 1
        end
        if do_absorb
          field.d = d
          field.absorb_iambic_passively x_a
          d = field.d
        end
        [ d, field ]
      end
      def constantspace
        @constantspace_mod = iambic_property ; nil
      end
      end  # #pay-one-back
      def abstract_field_list
        @abstract_field_list ||= begin
          fields_being_added_notification
          Mutable_Concrete_Field_List_.new
        end
      end
    end

    class Syntax__
      attr_accessor :d
      def build_syntax_proc afl
        mk = @monikate_p
        -> do
          a = afl.reduce [ ] do |m, fld|
            m.concat instance_exec( & fld.get_monikers_proc )
          end
          mk[ a ]
        end
      end
    MetaHell_::Fields::From.methods(
      :passive, :absorber, :absorb_iambic_passively
    ) do
      def monikate
        @monikate_p = iambic_property ; nil
      end
    end
    end

    class Abstract_Field_List__  # externally immutable! shared.
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
        clas = Parse::Curry_.const_get @class_i, false
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
