module Skylab::MetaHell

  module FUN::Parse::Curry

    Parse = FUN::Parse

    o = MetaHell::FUN_.o

    o[:parse_curry] = -> * input_a do
      Parse_.new( input_a ).get_conduit
    end

    class Conduit_
      def initialize parse
        @parse = parse
      end
      def [] *a
        p = @parse.dupe
        p.call_notify a
      end
      alias_method :call, :[]
      def curry
        -> *a do
          p = @parse.dupe
          p.curry_notify a
        end
      end
      def get_parse
        @parse.dupe
      end
      def _p
        @parse  # #shh - you can ruin everything
      end
    end

    Op_h_memoized_in_constant_ = -> const_i do
      -> do
        # NOTE - whenver this is called, the set gets locked down in perpetuity
        if const_defined? const_i, false
          const_get const_i, false
        else
          const_set const_i, Op_h_via_private_instance_methods_[ self ].freeze
        end
      end
    end

    Op_h_via_private_instance_methods_ =
      FUN::Parse::Op_h_via_private_instance_methods_

    Absorb_ = -> *a do
      op_h = self.op_h
      while a.length.nonzero?
        m = op_h[ a.shift ]
        send m, a
      end
      nil
    end

    class Parse_
      def initialize input_a
        @abstract_field_list = @call_p = @syntax = nil
        @exhaustion_p = nil
        absorb( * input_a )
      end
      protected :initialize  # because [#038]
      def get_conduit
        @conduit ||= Conduit_.new self
      end
      def dupe
        ba = base_args
        self.class.allocate.instance_exec do
          base_init( * ba )
          self
        end
      end
      def call_notify a  # assume was already duped. will mutate self, a
        instance_exec( *a, & @call_p )  # result!
      end
      def curry_notify a  # assume was already duped. will mutate self, a
        op_h = self.op_h
        while a.length.nonzero?
          m = op_h[ i = a.shift ]
          remove_from_curry_queue i
          send m, a
        end
        get_conduit
      end
      def op_h
        self.class.get_op_h
      end
      define_singleton_method :get_op_h, & Op_h_memoized_in_constant_[ :OP_H_ ]
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
    # #hacks-only
      def _field_a
        @abstract_field_list._field_a
      end
    protected
      def base_args
        [ @algorithm_p, @exhaustion_p, @abstract_field_list,
          @curry_queue_a, @call_p, @syntax ]
      end
      def base_init algo_p, exhaus_p, afl, cqa, calp, syn
        @algorithm_p = algo_p
        @exhaustion_p = exhaus_p
        @abstract_field_list = afl
        @curry_queue_a = ( cqa.dup if cqa )  # LOOK
        @call_p = calp
        @syntax = syn
        @field = nil
        nil
      end
      def set_abstract_field_list class_i, a
        # this just clobbers whatever is there without warning (which
        # presumably is acceptable behavior, to e.g a currying user).
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
          raise ::ArgumentError, "too many arguments (#{ a.length } for #{
            }#{ cq.length } ((#{ a.map( & :class ) }) for (#{
            }#{ @curry_queue_a * ', ' }))"
        end
        aa = [ ]
        while a.length.nonzero?
          aa << cq.shift << a.shift
        end
        absorb( *aa )
        nil
      end
      define_method :absorb, & Absorb_
      def execute
        instance_variable_defined? :@argv_a or fail 'where'
        @algorithm_p[ self, @argv_a ]
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
    private
      def algorithm a
        @algorithm_p = a.fetch 0 ; a.shift
        nil
      end
      def exhaustion a
        x = a.fetch 0 ; a.shift
        @exhaustion_p = false == x ? Exhaustion_when_false_ : x
        nil
      end
      Exhaustion_when_false_ = -> argv, ai do
        argv[ 0, ai ] = MetaHell::EMPTY_A_  # "consume" the amount that
        nil                                 # was matched
      end
      def curry_queue a
        @curry_queue_a = a.fetch 0 ; a.shift
        nil
      end
      def prepend_to_curry_queue a
        @curry_queue_a.unshift a.fetch 0 ; a.shift
        curry_queue_changed_notification
        nil
      end
      def call a
        @call_p = a.fetch 0 ; a.shift
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
        @argv_a = a.fetch 0 ; a.shift
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
        if a.first.respond_to? :id2name
          field = Parse::Field_.new
          field.absorb_notify a
        else
          field = a.fetch 0 ; a.shift
        end
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
    end

    class Syntax_
      define_method :absorb_notify, & FUN::Parse::Absorb_notify_
      def build_syntax_proc afl
        mk = @monikizer_p
        -> do
          a = afl.reduce [ ] do |m, fld|
            m.concat instance_exec( & fld.get_monikers_proc )
          end
          mk[ a ]
        end
      end
    protected
      def op_h
        self.class.const_get :OP_H_, false
      end
    private
      def monikizer a
        @monikizer_p = a.fetch 0 ; a.shift
        nil
      end

      OP_H_ = Op_h_via_private_instance_methods_[ self ]
    end

    class Abstract_Field_List_  # externally immutable! shared.
      def initialize class_i, a
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
      def reduce m, &b
        @field_a.reduce m, &b
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
