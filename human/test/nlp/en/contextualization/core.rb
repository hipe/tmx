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

      # -

      def channel_
        _DSL_shared_state.channel
      end

      def first_line_
        _DSL_shared_state.first_line
      end

      def second_line_
        _DSL_shared_state.second_line
      end

      def __build_DSL_state sets_p

        # -- read the values

        dsl = __build_DSL_values sets_p

        co = subject_class_.begin

        dsl.begin_by[ co ]

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
        em.reify_by do |y_p|
          expag.calculate [], & y_p
        end

        # -- write the state

        ss = __DSL_Shared_State.new
        em.cached_event_value.each_with_index do |s, d|
          ss[ LINES___.fetch( d ) ] = s
        end
        ss.channel = em.channel_symbol_array
        ss.freeze
      end

      LINES___ = [ :first_line, :second_line ]

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

      def begin_by & p
        @_DSL_setup_vals.begin_by = p
      end

      define_method :__DSL_Shared_State, ( Lazy_.call do

        X_NEC_DSL_Shared_State = ::Struct.new(
          :channel,
          :first_line,
          :second_line,
        )
      end )


      define_method :__DSL_Setup_Values, ( Lazy_.call do

        X_NEC_DSL_Setup_Values = ::Struct.new(
          :begin_by,
          :channel,
          :emission_proc,
          :selection_stack,
          :subject_association,
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
