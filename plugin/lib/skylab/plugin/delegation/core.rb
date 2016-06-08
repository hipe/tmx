module Skylab::Plugin

  module Delegation  # see [#010]

    class << self

      def _call mod, * x_a
        edit_module_via_iambic mod, x_a
      end

      alias_method :[], :_call
      alias_method :call, :_call

      def edit_module_via_iambic mod, x_a

        st = Common_::Polymorphic_Stream.via_array x_a

        if st.unparsed_exists

          Here_::Actors_::Edit[ mod, st ]
        else

          mod.module_exec do

            if ! const_defined? :DELEGATING_MEMBER_I_A__, false
              const_set :DELEGATING_MEMBER_I_A__, []  # 1 of 2
            end
            extend Module_Methods___
            include Instance_Methods___
          end
        end
        NIL_
      end
    end  # >>

    module Module_Methods___

      def has_delegated_member? sym
        self::DELEGATING_MEMBER_I_A__.include? sym
      end

      def members
        self::DELEGATING_MEMBER_I_A__.dup
      end

      def inherited otr
        _a = otr::DELEGATING_MEMBER_I_A__.dup
        otr.const_set :DELEGATING_MEMBER_I_A__, _a  # 2 of 2
      end

   private

      def delegate_to_dependency * m_a

        bu = BUILDER_FOR_SINGLE_DEPENDENCY___

        m_a.each do | m |

          _p = bu.build_method m
          _accept_delegated_method m, _p
        end

        NIL_
      end

      def delegate * x_a

        st = Common_::Polymorphic_Stream.via_array x_a

        begin

          pi = Delegating_Phrase_Interpreter_.new st
          pi.interpret_some_delegating_phrase

          bu = pi.resolve_some_builder
          pi.some_method_name_array.each do | m |

            _p = bu.build_method m
            _accept_delegated_method m, _p
          end

          if st.no_unparsed_exists
            break
          end
          redo
        end while nil
      end

      def _accept_delegated_method m, p

        const_get( :DELEGATING_MEMBER_I_A__, false ).push m
        define_method m, p
        NIL_
      end
    end

    class Phrase_Interpreter_

      def initialize st
        @_up = st
      end

      def absorb_any_sub_phrases_  # assumes some tokens

        p = self.class.__white_proc
        st = @_up

        begin

          m = p[ st.current_token ]
          m or break

          did = true
          st.advance_one

          _kp = send m
          _kp or self._SANITY  # future-proofing

          if st.no_unparsed_exists
            break
          end

          redo
        end while nil

        did
      end

      class << self

        def __white_proc
          @___white_proc ||= __build_white_proc
        end

        def __build_white_proc

          -> x do
            if x.respond_to? :id2name
              m = :"#{ x }="
              if private_method_defined? m
                m
              end
            end
          end
        end
      end  # >>

      def gets_one_polymorphic_value
        @_up.gets_one
      end
    end

    class Delegating_Phrase_Interpreter_ < Phrase_Interpreter_

      def initialize st

        @for_single_method = nil
        @if_p = nil
        @receiver_x_i = nil
        @_method_name_p = nil  # defaulted in place
        super
      end

      def interpret_some_delegating_phrase

        absorb_any_sub_phrases_
        _absorb_some_method_name_or_names
      end

      def interpret_any_delegating_phrase  # #storypoint-125

        _did = absorb_any_sub_phrases_
        if _did
          _absorb_some_method_name_or_names
          ACHIEVED_
        else
          _absorb_any_array_as_method_names
        end
      end

      def resolve_some_builder
        if @if_p
          __build_builder_with_if
        else
          _build_builder_without_if
        end
      end

    private

      def __build_builder_with_if

        _ = _build_builder_without_if

        Here_::Actors_::Build_builder_with_if[ @if_p, _ ]
      end

      def _build_builder_without_if

        p = @_method_name_p || IDENTITY_

        if @receiver_x_i

          Builder_for_Multiple_Dependencies___.new p, @receiver_x_i
        else

          Builder_for_Single_Dependency__.new p
        end
      end

      def _absorb_some_method_name_or_names

        did = _absorb_any_array_as_method_names

        if ! did

          if @_up.current_token.respond_to? :id2name
            @method_name_a = [ @_up.gets_one ]
            did = true
          end
        end

        if ! did
          raise ::ArgumentError, __say_cant_resolve_method_names
        end

        NIL_
      end

      def __say_cant_resolve_method_names

        _ = Strange_[ @_up ]
        "can't resolve delegator method name or names from #{ _ }"
      end

      def _absorb_any_array_as_method_names

        x = @_up.current_token
        if ::Array.try_convert x
          @_up.advance_one
          @method_name_a = x
          ACHIEVED_
        end
      end

      def if=

        @if_p = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def to=

        @receiver_x_i = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def to_method=

        @for_single_method = true
        as_sym = gets_one_polymorphic_value
        _receive_name_proc -> _ { as_sym }
      end

      def with_infix=

        prefix_i = gets_one_polymorphic_value
        suffix_i = gets_one_polymorphic_value
        _receive_name_proc -> sym { :"#{ prefix_i }#{ sym }#{ suffix_i }" }
      end

      def with_suffix=

        suffix_i = gets_one_polymorphic_value
        _receive_name_proc -> sym { :"#{ sym }#{ suffix_i }" }
      end

      def _receive_name_proc p

        if @_method_name_p
          raise ::ArgumentError, __say_name_proc
        end
        @_method_name_p = p
        KEEP_PARSING_
      end

      def __say_name_proc
        "can't have more than one name proc"
      end

    public

      def some_method_name_array

        if @for_single_method && 1 < @method_name_a.length
          raise ::ArgumentError, __say_single
        end

        @method_name_a
      end

      def __say_single

        _s_a = @method_name_a.map do | m |
          Home_.lib_.basic::String.via_mixed m
        end

        "'to_method' is for single methods only. cannot delegate these #{
          }to the same method: #{ _s_a * ', ' }"
      end
    end

    class Builder__

      def initialize nm_p
        nm_p or self._WHERE
        @_method_name_p = nm_p
      end
    end

    class Builder_for_Single_Dependency__ < Builder__

      def build_method m

        m_ = @_method_name_p[ m ]

        -> *a, &p do

          @plugin_dependency_p[].send m_, * a, & p
        end
      end

      def build_normal_proc m

        m_ = @_method_name_p[ m ]

        -> a, p do
          @plugin_dependency_p[].send m_, * a, & p
        end
      end
    end

    IDENTITY_ = -> x { x }

    BUILDER_FOR_SINGLE_DEPENDENCY___ =

      Builder_for_Single_Dependency__.new IDENTITY_

    class Builder_for_Multiple_Dependencies___ < Builder__

      def initialize nm_p, sym_x

        if AT_BYTE___ == sym_x.id2name.getbyte( 0 )

          __when_ivar sym_x

        else

          __when_method sym_x
        end

        super nm_p
      end

      AT_BYTE___ = '@'.getbyte 0

      def build_method m
        @_build_method[ m ]
      end

      def build_normal_proc m

        send :"__build_normal_proc_when_technique_is__#{ @_technique }__", m
      end

      def __when_ivar ivar

        @_technique =  :ivar
        @__ivr = ivar

        @_build_method = -> m do

          m_ = @_method_name_p[ m ]

          -> * a, & p do

            instance_variable_get( ivar ).send m_, * a, & p
          end
        end

        NIL_
      end

      def __when_method dependency_reader_name

        @_technique = :method
        @__dep_rdr_m_n = dependency_reader_name

        @_build_method = -> m do

          m_ = @_method_name_p[ m ]

          -> * a, & p do

            send( dependency_reader_name ).send m_, * a, & p
          end
        end

        NIL_
      end

      def __build_normal_proc_when_technique_is__ivar__ m

        ivar = @__ivr

        m_ = @_method_name_p[ m ]

        -> a, p do

          instance_variable_get( ivar ).send m_, * a, & p
        end
      end

      def __build_normal_proc_when_technique_is__method__ m

        dependency_reader_name = @__dep_rdr_m_n

        m_ = @_method_name_p[ m ]

        -> a, p do

          send( dependency_reader_name ).send m_, * a, & p
        end
      end
    end

    module Instance_Methods___

      def initialize dep=nil

        # notificate :initialization  # will away

        if dep
          @plugin_dependency_p = -> { dep }
        end

        super()
      end

      def members
        self.class.members
      end
    end

    Strange_ = -> st do
      Home_.lib_.basic::String.via_mixed st.current_token
    end

    Here_ = self
  end
end
