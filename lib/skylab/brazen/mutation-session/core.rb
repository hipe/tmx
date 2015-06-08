module Skylab::Brazen

  # ->

    class Mutation_Session  # see [#023]

      # an attempt to generalize prepends, appends, and removes
      # for all collections of associated entites of all entities
      # (and now entities too.)  :1 is the only tenet not pictured.

      class << self

        def create x_a, cls, & x_p  # :2

          o = new( & x_p )
          o.receive_argument_array x_a
          o.subject_component_class = cls
          o._macro_operation_method_name = :__create
          o.execute
        end

        def edit x_a, subj_o, & x_p  # :3

          o = new( & x_p )
          o.receive_argument_array x_a
          o.subject_component = subj_o
          o.subject_component_class = subj_o.class
          o._macro_operation_method_name = :__edit
          o.execute
        end

        def interpret arg_st, cls, & x_p  # :5

          o = new( & x_p )
          o.arg_st = arg_st
          o.subject_component_class = cls
          o._macro_operation_method_name = :__interpret
          o.execute
        end

        def event_class sym  # :#twice
          MS_::Event_Factory_.class_for sym
        end
      end  # >>

      def initialize & x_p

        @subject_component = nil
        @x_p = x_p
      end

      def receive_argument_array x_a
        @arg_st = Callback_::Polymorphic_Stream.new x_a
        NIL_
      end

      attr_writer :arg_st, :_macro_operation_method_name
      attr_writer :subject_component, :subject_component_class

      def execute
        if @arg_st.unparsed_exists
          send @_macro_operation_method_name
        else
          raise ::ArgumentError  # until covered & designed
        end
      end

      def __create  # #note-15 how `create` differs from `edit` ..

        @_fully_or_passively = :fully
        _build_subject_component_via_argument_stream
      end

      def __interpret

        @_fully_or_passively = :passively
        _build_subject_component_via_argument_stream
      end

      def _build_subject_component_via_argument_stream

        ok = true
        otr_op_a = nil
        set_op_a = []

        _build_operation_stream.each do | op |

          ok = op.resolve_components
          ok or break
          if :set == op.name_symbol
            set_op_a.push op
          else
            ( otr_op_a ||= [] ).push op
          end
        end

        if ok
          __construct_via_set_and_other_operations set_op_a, otr_op_a
        else
          ok
        end
      end

      def __construct_via_set_and_other_operations set_op_a, otr_op_a

        if @arg_st.unparsed_exists && :passively != @_fully_or_passively
          raise ::ArgumentError, @arg_s.current_token
        end

        x = if set_op_a.length.zero?

          if otr_op_a
            @subject_component_class.new_empty_for_mutation_session
          else
            self._DESIGN_ME
          end
        else
          __construct_via_set_operations set_op_a
        end

        if x && otr_op_a
          __mutate_created_component otr_op_a, x
        else
          x
        end
      end

      def __construct_via_set_operations set_op_a

        assoc_i_a = []
        value_x_a = []

        set_op_a.each do | operation |

          assoc_i_a.push operation.association_symbol
          value_x_a.push operation.object_component_x
        end

        @subject_component_class.send(  # :8
          :"new_via__#{ assoc_i_a * AND___ }__",
          * value_x_a )
      end

      AND___ = '_and_'

      def __mutate_created_component otr_op_a, x

        changed = false
        ok = true

        otr_op_a.each do | op |
          op.__receive_subject_component x
          ok = op.via_components_execute
          ok or break
          op.change_did_occur and changed = true
        end

        if ok && changed
          ok = x.receive_changed_during_mutation_session( & @x_p )
        end

        ok && x
      end

      def __edit  # #note-70 how `edit` differs from `create` ..

        change_did_occur = false
        ok = true
        result_x_a = nil

        _build_operation_stream.each do | op |

          ok = op.execute_fully
          ok or break

          if op.change_did_occur

            change_did_occur = true

            if op.has_non_boolean_result

              ( result_x_a ||= [] ).push op.full_execution_result_x
            end
          elsif op.has_non_boolean_result

            ( result_x_a ||= [] ).push NIL_
          end
        end

        if ok
          __result_of_edit change_did_occur, result_x_a
        else
          ok
        end
      end

      def __result_of_edit change_did_occur, result_x_a

        if @arg_st.unparsed_exists
          raise ::ArgumentError, @arg_s.current_token
        end

        if change_did_occur

          ok = @subject_component.receive_changed_during_mutation_session(
            & @x_p )

          ok && ( result_x_a || ok )  # (e.g number of bytes written)
        else

          NIL_  # else the simple action writes redundantly (coverd)
        end
      end

      def _build_operation_stream

        # (if we had suppport for custom operations, we would load them here)

        arg_st = @arg_st

        full_modifiers_box, full_op_box = Static_dictionaries___[]

        _parse_one = -> do

          # (before parsing each operation reset below boxes back to being
          #  the full boxes because each next predicate is not inflected
          #  by each previous predicate, but a blank state.)

          @available_modifiers_box = full_modifiers_box
          @available_op_box = full_op_box

          moddy = @available_modifiers_box[ arg_st.current_token ]
          if moddy
            modifier_a = __parse_modifiers moddy
          end

          op = @available_op_box[ arg_st.current_token ]

          if op
            op_o = _new_op op

            if modifier_a
              __write_modifiers_into_operation modifier_a, op_o
            end

            op_o.__parse_remainder self
          else
            raise expecting_exception_( @available_op_box, :operation_name )
          end
        end

        Callback_.stream do
          if arg_st.unparsed_exists
            _parse_one[]
          end
        end
      end

      def __parse_modifiers moddy  # has side-effects & produces result

        # #note-215 the current token parses as a modifier ..

        arg_st = @arg_st
        modifier_a = []

        begin  # with each modifier reduce the boxes & parse any next modifier

          arg_st.advance_one
          modifier_a.push moddy.model.parse arg_st

          available_modifiers_box = Callback_::Box.new
          available_op_box = Callback_::Box.new

          moddy.op_a.each do | op |

            available_op_box.add op.name_symbol, op

            op.to_modifier_stream.each do | mdfr |
              available_modifiers_box.touch mdfr.head_token do
                Modifier_Aggregation__.new
              end.register mdfr, op
            end
          end

          moddy = available_modifiers_box[ arg_st.current_token ]
          if moddy
            redo
          end

          break
        end while nil

        @available_modifiers_box = available_modifiers_box
        @available_op_box = available_op_box

        modifier_a
      end

      def __write_modifiers_into_operation modifier_a, op

        modifier_a.each do | modi |
          if modi.is_flag
            op.send :"#{ modi.head_token }="
          else
            op.send :"#{ modi.head_token }=", modi.x
          end
        end
        NIL_
      end

      def _new_op op

        op.new( @arg_st,
          @subject_component,
          @subject_component_class,
          & @x_p )
      end

      def expecting_exception_ sym_or_box, nonterminal_symbol

        nt_s = Callback_::Name.
          via_variegated_symbol( nonterminal_symbol ).as_human

        _msg = if sym_or_box.respond_to? :id2name

          "expecting '#{ sym_or_box }' for #{ nt_s }"
        else

          _s_a =sym_or_box.a_.map do | k |
            "'#{ k }'"
          end

          "for #{ nt_s } expecting #{ _s_a * ' or ' }"
        end

        _ctxt = if @arg_st.unparsed_exists
          _x = @arg_st.current_token
          " (had: #{ Brazen_.lib_.basic::String.via_mixed _x })"
        else
          " at end of input"
        end

        ::ArgumentError.new "#{ _msg }#{ _ctxt }"
      end

      Static_dictionaries___ = Callback_.memoize do

        mdfr_bx = Callback_::Box.new
        op_bx = Callback_::Box.new

        mod = MS_::Operations___

        mod.constants.each do | const |

          op = mod.const_get const, false
          op_bx.add op.name_symbol, op

          st = op.to_modifier_stream
          begin
            mdfr = st.gets
            mdfr or break

            mdfr_bx.touch mdfr.head_token do

              Modifier_Aggregation__.new

            end.register mdfr, op

            redo
          end while nil
        end

        [ mdfr_bx, op_bx ]
      end

      class Operation_

        # #note-340 on the importance of executing this at every step

        def initialize name_symbol

          @has_non_boolean_result = false
          @modifiers = []
          @name_symbol = name_symbol
        end

        attr_reader :association_symbol
        attr_reader :change_did_occur
        attr_accessor :has_non_boolean_result
        attr_reader :name_symbol
        attr_reader :object_component_x
        attr_writer :operation_category_symbol

        def to_modifier_stream

          Callback_::Stream.via_nonsparse_array @modifiers
        end

        def takes_modifier mod_mod_sym=nil, name_sym

          o = Modifier___.new name_sym
          if mod_mod_sym
            o[ mod_mod_sym ] = true
          end

          @modifiers.push o

          NIL_
        end

        # ~ near & for instances

        def new * x_a, & x_p
          otr = dup
          otr.__init( * x_a, & x_p )
          otr
        end

      protected def __init arg_st, subj_comp, subj_comp_class, & oes_p

          @arg_st = arg_st
          @change_did_occur = false
          @on_event_selectively = oes_p
          @subject_component = subj_comp
          @subject_component_class = subj_comp_class
          @via_ = nil  # when used
          NIL_
        end

        def __receive_subject_component x
          @subject_component = x
          NIL_
        end

        def __parse_remainder parse_event_agent  # result in self

          arg_st = @arg_st

          if @name_symbol == arg_st.current_token

            arg_st.advance_one

            @association_symbol = arg_st.gets_one
            self
          else
            self._COVER_ME
            raise parse_agent.expecting_exception_ @name_symbol, :operation_name
            UNABLE_
          end
        end

        def execute_fully  # a common implementation

          _ok = resolve_components
          _ok && via_components_execute
        end

        def full_execution_result_x
          @full_execution_result_x
        end

        def resolve_components

          arg_st = @arg_st

          asc_x = @subject_component_class.send(  # :7
            :"__#{ @association_symbol }__association_for_mutation_session" )

          via_sym = @via_

          x_p = @on_event_selectively

          if via_sym  # :6

            x = asc_x.send :"new_via__#{ via_sym }__", arg_st.gets_one, & x_p
            ok = x && ACHIEVED_

          elsif asc_x.respond_to? :interpret_for_mutation_session  # :5

            x = asc_x.interpret_for_mutation_session arg_st, & x_p
            ok = x && ACHIEVED_

          else  # :4
            arg = asc_x[ arg_st, & x_p ]
            if arg
              x = arg.value_x
              ok = ACHIEVED_
            else
              ok = arg
            end
          end

          if ok
            @object_component_x = x
            ACHIEVED_
          else
            ok
          end
        end

        def mutable_body_
          @subject_component.mutable_body_for_mutation_session
        end

        def event_class_ sym  # placeholder, #twice
          MS_::Event_Factory_.class_for sym
        end
      end

      class Modifier_Aggregation__

        def initialize

          @p = -> mdfr, op do

            @model = mdfr
            @op_a = [ op ]

            @p = -> mdfr_, op_ do

              if @model == mdfr_
                @op_a.push op_
              else
                raise ::ArgumentError, __say_mismatch( mdfr_ )
              end
              NIL_
            end
            NIL_
          end
        end

        attr_reader :model, :op_a

        def __say_mismatch mdfr
          "modifier mismatch: #{ @model.description } then #{
           }#{ mdfr.description }"
        end

        def register mdfr, op
          @p[ mdfr, op ]
        end
      end

      Modifier___ = ::Struct.new :head_token, :is_flag, :x do

        def description
          "(name: #{ head_token }, is_flag: #{ is_flag ? 'true' : 'false' })"
        end

        def parse arg_st

          if is_flag
            new
          else
            new_with_value arg_st.gets_one
          end
        end

        alias_method :new, :dup

        def new_with_value x
          o = dup
          o.x = x
          o
        end
      end

      # ~

      module Collection_Methods_

        def initialize( * )

          @do_check_for_redundancy_ = false
          @_xtra_args = nil
          super
        end

        def unless_present=

          @do_check_for_redundancy_ = true
          NIL_
        end

        def using= x

          ( @_xtra_args ||= [] ).push x
          NIL_
        end

        def via= x

          @via_ = x
          NIL_
        end

        def via_components_execute

          if @do_check_for_redundancy_

            if __maybe_emit_because_operation_would_be_redundant

              ACHIEVED_
            else
              _send_the_operation
            end
          else
            _send_the_operation
          end
        end

        def __maybe_emit_because_operation_would_be_redundant

          send :"__#{ @operation_category_symbol }__would_be_redundant"
        end

        def __add__would_be_redundant

          has = _has_equivalent_object

          if has
            __maybe_send_already_added_event
            true
          else
            false
          end
        end

        def __remove__would_be_redundant

          has = _has_equivalent_object

          if has
            false
          else
            __maybe_send_not_present_event
            true
          end
        end

        def _has_equivalent_object

          @subject_component.send(
            :"has_equivalent__#{ @association_symbol }__for_mutation_session",
            @object_component_x )
        end

        def __maybe_send_already_added_event

          @on_event_selectively.call :error, :entity_already_added do

            event_class_( :entity_already_added ).new_with(
              :entity, @object_component_x,
              :entity_collection, @subject_component,
              :ok, nil  # overwrite to change error into info
            )
          end
          NIL_
        end

        def __maybe_send_not_present_event

          @on_event_selectively.call :error, :entity_not_found do

            event_class_( :entity_not_found ).new_with(

            # ev = event_class_( :entity_not_found ).new_with(
              :entity, @object_component_x,
              :entity_collection, @subject_component,
              :ok, nil
            )
          end
          NIL_
        end

        def _send_the_operation

          ok_x = mutable_body_.send(
            :"__#{ @name_symbol }__object_for_mutation_session",
            * @_xtra_args,
            @object_component_x,
            & @on_event_selectively )

          if ok_x
            when_the_operation_succeeded_ ok_x

          else
            ok_x
          end
        end

        def when_the_operation_succeeded_ ok_x

          @change_did_occur = true

          @full_execution_result_x = if @has_non_boolean_result
            ok_x
          else
            ACHIEVED_
          end

          ACHIEVED_
        end
      end

      # ~

      Autoloader_[ Operations___ = ::Module.new, :boxxy ]

      MS_ = self

    end

    # <-
end
