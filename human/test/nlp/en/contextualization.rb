module Skylab::Human::TestSupport

  module NLP::EN::Contextualization

    def self.[] tcc
      tcc.include self
    end

    module DSL

      def self.[] tcc
        Expect_Event[ tcc ]
        tcc.send :define_singleton_method, :given, Emit_by___
        tcc.include self
      end

      # -

        Emit_by___ = -> & p do

          yes = true ; x = nil
          define_method :_emission_result_state do
            if yes
              yes = false
              x = __build_emission_result_state p
            end
            x
          end
        end

      # -

      def testcase_family_4_customization_ o

        # :#C15n-testcase-family-4 ([ze])

        # (the below is a sketch for how we might style it in [ze] niCLI..)

        same = -> asc do
          asc.name.as_human
        end

        o.to_say_selection_stack_item = -> asc do
          if asc.name
            same[ asc ]
          end
        end

        o.to_say_subject_association = same

        NIL_
      end

      # -

      def exception_class_
        _emission_result_state.exception.class
      end

      def channel_
        _emission_result_state.channel
      end

      def first_line_
        _emission_result_state.first_line
      end

      def second_line_
        _emission_result_state.second_line
      end

      def event_
        _emission_result_state.event
      end

      def __build_emission_result_state sets_p

        # -- read the values

        dsl = __build_DSL_mutable_argument_store sets_p

        m = dsl.state_building_method
        if m
          send m, dsl
        else
          __build_conventional_result_state dsl
        end
      end

      def __build_exception_result_state dsl

        co = _subject_class_begin

        ex = dsl.to_build_exception[ co, dsl ]

        o = __Result_State_for_Exception.new
        o.exception = ex

        _s_a = ex.message.split NEWLINE_

        _s_a.each_with_index do |s, d|
          o[ LINES__.fetch( d ) ] = s
        end

        o
      end

      def __build_conventional_result_state dsl

        co = _common_c15n_beginning dsl

        expag = co.expression_agent  # eek/meh (get it back from ourself)

        # -- run the thing

        _recording_oes_p = event_log.handle_event_selectively

        _use_this = co.emission_handler_via_emission_handler( & _recording_oes_p )

        _use_this.call( * dsl.channel, & dsl.emission_proc )

        a = remove_instance_variable( :@event_log ).flush_to_array
        1 == a.length or fail
        em = a.first

        if em.is_expression
          is_event = false
          x = expag.calculate [], & em.expression_proc
        else
          is_event = true
          x = em.cached_event_value
        end

        # -- write the state

        ss = __Result_State_for_Deep_Emission.new
        if is_event
          s_a = []
          x.express_into_under s_a, expag
          ss.event = x
        else
          s_a = x ; x = nil
        end
        _write_two_lines ss, s_a
        ss.channel = em.channel_symbol_array
        ss.freeze
      end

      def __build_lines_only_result_state dsl

        co = _common_c15n_beginning dsl

        _s_a = co.express_into []

        ss = __Result_State_for_Lines_Only.new
        _write_two_lines ss, _s_a
        ss.freeze
      end

      def _write_two_lines ss, s_a

        s_a.each_with_index do |s, d|
          ss[ LINES__.fetch( d ) ] = s
        end
      end

      LINES__ = [ :first_line, :second_line ]

      def _common_c15n_beginning dsl

        co = _subject_class_begin

        dsl.to_begin[ co ]

        x = dsl.selection_stack
        if x
          co.selection_stack = x
        end

        x = dsl.subject_association
        if x
          co.subject_association = x
        end

        _expag = common_expag_

        co.expression_agent = _expag
        co
      end

      def _subject_class_begin
        subject_class_.begin
      end

      def __build_DSL_mutable_argument_store sets_p

        @_DSL_setup_vals = __DSL_Setup_Values.new

        _record_these = -> * i_a, & msg_p do
          @_DSL_setup_vals.channel = i_a
          @_DSL_setup_vals.emission_proc = msg_p
        end

        instance_exec _record_these, & sets_p

        remove_instance_variable :@_DSL_setup_vals
      end

      def selection_stack * x_a
        @_DSL_setup_vals.selection_stack = x_a
      end

      def subject_association x
        @_DSL_setup_vals.subject_association = x
      end

      def exception_by & p
        @_DSL_setup_vals.to_build_exception = p
        @_DSL_setup_vals.state_building_method = :__build_exception_result_state ; nil
      end

      def lines_only
        @_DSL_setup_vals.state_building_method = :__build_lines_only_result_state ; nil
      end

      def begin_by & p
        @_DSL_setup_vals.to_begin = p
      end

      define_method :__Result_State_for_Exception, ( Lazy_.call do

        X_NEC_DSL_SharedState_for_Exception = ::Struct.new(
          :exception,
          :first_line,
          :second_line,
        )
      end )

      define_method :__Result_State_for_Deep_Emission, ( Lazy_.call do

        X_NEC_Result_State_for_Deep_Emmission = ::Struct.new(
          :channel,
          :event,
          :first_line,
          :second_line,
        )
      end )

      define_method :__Result_State_for_Lines_Only, ( Lazy_.call do

        X_NEC_Result_State_for_Lines_Only = ::Struct.new(
          :first_line,
          :second_line,
        )
      end )

      define_method :__DSL_Setup_Values, ( Lazy_.call do

        X_NEC_DSL_Setup_Values = ::Struct.new(
          :channel,
          :emission_proc,
          :selection_stack,
          :state_building_method,
          :subject_association,
          :to_begin,
          :to_build_exception,
        )
      end )

      define_method :no_name_, ( Lazy_.call do
        class X_NEC_DSL_NoName
          def name
            NOTHING_
          end
          new
        end
      end )

      def assoc_ sym
        Common_::Name.via_variegated_symbol sym
      end

      # -
    end

    def subject_class_
      NLP_EN_.lib::Contextualization
    end
  end
end
# #tombstone: butter
