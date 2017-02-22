module Skylab::Snag

  class Models_::NodeCollection

    class Magnetics::Expression_of_OpenNodes_via_Arguments

      def initialize & oes_p
        @oes_p = oes_p
      end

      attr_writer(
        :filesystem,
        :kernel,
        :number_limit,
        :upstream_identifier,
      )

      attr_accessor :name

      def bound_call_against_argument_scanner st

        st.unparsed_exists and self._SANITY

        Common_::BoundCall.via_receiver_and_method_name self, :execute
      end

      def execute

        _st = @kernel.call :criteria, :to_criteria_stream, & @oes_p

        s = 'open'
        found = _st.flush_until_detect do | crit |
          s == crit.natural_key_string
        end

        if found

          self.__TODO_execute_open_report_via_found found
        else
          __execute_via_default_report
        end
      end

      def __execute_via_default_report

        _s_a = %w( nodes that are tagged with #open )

        st = @kernel.call :criteria,
          :issues_via_criteria,
          :criteria, _s_a,
          :upstream_identifier, @upstream_identifier,
          & @oes_p

        if st
          if @number_limit
            __wrap_this_in_number_limiter st
          else
            st
          end
        else
          st
        end
      end

      def __wrap_this_in_number_limiter st  # (would-be `limit_by` :[#ca-016])

        d = @number_limit
        d ||= -1

        p = if 1 > d
          if -1 == d
            -> do
              st.gets
            end
          else
            EMPTY_P_
          end
        else

          -> do
            x = st.gets
            if x
              d -= 1
              if d.zero?
                p = EMPTY_P_
              end
            end
            x
          end
        end

        Common_.stream do
          p[]
        end
      end

      class << self
        def name_function
          @___nf ||= Common_::Name.via_module( self )
        end
      end  # >>
    end

    NILADIC_TRUTH_ = -> { true }
  end
end
