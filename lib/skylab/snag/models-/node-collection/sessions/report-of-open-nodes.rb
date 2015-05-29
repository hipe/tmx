module Skylab::Snag

  class Models_::Node_Collection

    Sessions = ::Module.new

    class Sessions::Report_of_Open_Nodes

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

      def bound_call_against_polymorphic_stream st

        st.unparsed_exists and self._SANITY

        Callback_::Bound_Call.via_receiver_and_method_name self, :execute
      end

      def execute

        _st = @kernel.call :criteria, :to_criteria_stream, & @oes_p

        s = 'open'
        found = _st.detect do | crit |
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
          :criteria_to_stream,
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

      def __wrap_this_in_number_limiter st  # (would-be `limit_by` :[#cb-016])

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

        Callback_.stream do
          p[]
        end
      end

      class << self
        def name_function
          @___nf ||= Callback_::Name.via_module( self )
        end
      end  # >>
    end

    if false
    def bld_terse_node_yieldee
      m = @lines.method( :<< )
      ::Enumerator::Yielder.new do |n|
        @lines << n.first_line
        n.extra_line_a.each(& m ) if n.extra_lines_count.nonzero?
        nil
      end
    end
    end

    NILADIC_TRUTH_ = -> { true }
  end
end
