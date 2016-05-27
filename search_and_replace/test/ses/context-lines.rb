module Skylab::SearchAndReplace::TestSupport

  module SES::Context_Lines

    def self.[] tcc
      tcc.extend SES::Common_DSL::ModuleMethods
      tcc.include SES::Common_DSL::InstanceMethods
      tcc.include SES::InstanceMethods
      tcc.include self
    end

    # -
      def match_controller_at_offset_ es, d

        0 > d and self._NO

        st = match_controller_stream_for_ es
        x = st.gets
        d.times do
          x = st.gets
        end
        x
      end

      def _WOULD_BE_for_ st

        @_mag_dsl_st = st
        yield
        remove_instance_variable :@_mag_dsl_st
        s = st.gets
        if s
          fail __for_say_unexp s
        end
      end

      def _WOULD_BE_nothing_for_ st
        if st
          fail __for_say_stream
        end
      end

      def _WOULD_BE_UNDERSCORE_ONLY_ line_without_newline

        x = @_mag_dsl_st.gets
        if x
          s = assemble_ x
          s_ = s.chomp!
          if s_
            s_.should eql line_without_newline
          else
            fail __for_say_no_newline s
          end
        else
          fail __for_say_miss line_without_newline
        end
      end

      def __for_say_stream ; "unexpected stream (expected no lines ergo false-ish)" ; end
      def __for_say_unexp s ; "unexpected line: #{ s.inspect }" ; end
      def __for_say_no_newline s ; "did not have a newline: #{ s.inspect }" ; end
      def __for_say_miss s ; "missing expected line: #{ s.inspect }" ; end

      def _WOULD_BE_one_line_ st
        _ = st.gets
        _2 = st.gets
        _2 and fail
        assemble_ _
      end

      def lines_before_
        context_lines_before_during_after_.fetch 0
      end

      def lines_during_
        context_lines_before_during_after_.fetch 1
      end

      def lines_after_
        context_lines_before_during_after_.fetch 2
      end

      def context_lines_before_during_after_via_ num_before, num_after, mc_d=0

        _es = mutated_edit_session_

        mc = _Nth_match_controller mc_d, _es

        mc.to_contextualized_sexp_line_streams num_before, num_after
      end
    # -
  end
end
# #history: splintered
