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
          define_method :_DSL_shared_state do
            if yes
              yes = false
              x = __build_DSL_state p
            end
            x
          end
        end

      # -

      def testcase_family_4_customization_ o

        # :#C15n-testcase-family-4 ([ze])

        # (the below is a sketch for how we might style it in [ze] niCLI..)
        #
        # (order matters while #open [#043] because it's building a magnetic
        # function stack, so highest level (last to run) first)

        _but = o.express_trilean.classically.but

        _but.on_failed = -> ip, lemz do  # surface parts

          ip.prefixed_cojoinder = nil
          ip.verb_subject = nil
          ip.inflected_verb = "couldn't #{ lemz.verb_lemma }"
          ip.verb_object = lemz.verb_object
          ip.suffixed_cojoinder = "because"
          NIL_
        end

        o.express_subject_association.integratedly

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
        _DSL_shared_state.exception.class
      end

      def channel_
        _DSL_shared_state.channel
      end

      def first_line_
        _DSL_shared_state.first_line
      end

      def second_line_
        _DSL_shared_state.second_line
      end

      def event_
        _DSL_shared_state.event
      end

      def __build_DSL_state sets_p

        # -- read the values

        dsl = __build_DSL_values sets_p

        m = dsl.state_building_method
        if m
          send m, dsl
        else
          __build_conventional_state dsl
        end
      end

      def __build_exception_state dsl

        co = _subject_class_begin

        ex = dsl.to_build_exception[ co, dsl ]

        o = __DSL_Shared_State_for_Exception.new
        o.exception = ex

        _s_a = ex.message.split NEWLINE_

        _s_a.each_with_index do |s, d|
          o[ LINES__.fetch( d ) ] = s
        end

        o
      end

      def __build_conventional_state dsl

        co = _subject_class_begin

        dsl.to_begin[ co ]

        co.selection_stack = dsl.selection_stack

        co.subject_association = dsl.subject_association

        expag = common_expag_

        co.expression_agent = expag

        # -- run the thing

        _recording_oes_p = event_log.handle_event_selectively

        _use_this = co.emission_handler_via_emission_handler( & _recording_oes_p )

        _use_this.call( * dsl.channel, & dsl.emission_proc )

        a = remove_instance_variable( :@event_log ).flush_to_array
        1 == a.length or fail
        em = a.first
        is_event = false
        em.reify_by do |y_p|
          if y_p.arity.zero?
            is_event = true
            y_p[]
          else
            expag.calculate [], & y_p
          end
        end
        x = em.cached_event_value

        # -- write the state

        ss = __DSL_Shared_State.new
        if is_event
          s_a = []
          x.express_into_under s_a, expag
          ss.event = x
        else
          s_a = x ; x = nil
        end

        s_a.each_with_index do |s, d|
          ss[ LINES__.fetch( d ) ] = s
        end

        ss.channel = em.channel_symbol_array
        ss.freeze
      end

      LINES__ = [ :first_line, :second_line ]

      def _subject_class_begin
        subject_class_.begin
      end

      def __build_DSL_values sets_p

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
        @_DSL_setup_vals.state_building_method = :__build_exception_state ; nil
      end

      def begin_by & p
        @_DSL_setup_vals.to_begin = p
      end

      define_method :__DSL_Shared_State_for_Exception, ( Lazy_.call do

        X_NEC_DSL_SharedState_for_Exception = ::Struct.new(
          :exception,
          :first_line,
          :second_line,
        )
      end )

      define_method :__DSL_Shared_State, ( Lazy_.call do

        X_NEC_DSL_Shared_State = ::Struct.new(
          :channel,
          :event,
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
      Home_::NLP::EN::Contextualization
    end
  end
end
