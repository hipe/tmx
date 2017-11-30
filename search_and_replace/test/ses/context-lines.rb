module Skylab::SearchAndReplace::TestSupport

  module SES::Context_Lines

    def self.[] tcc
      tcc.extend SES::Common_DSL::ModuleMethods
      tcc.include SES::Common_DSL::InstanceMethods
      tcc.include SES::InstanceMethods
      tcc.include SES::Block_Stream::InstanceMethods  # want_atoms_
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    module Module_Methods___

      def num_lines_before d
        define_method :_CL_num_lines_before do
          d
        end
      end

      def num_lines_after d
        define_method :_CL_num_lines_after do
          d
        end
      end

      def during_around_match_controller_at_index d
        define_method :_CL_match_controller_index do
          d
        end
      end

      def mutate_edit_session_for_context_lines_by & p

        # we decide for the client that as a rule, wherever such a mutation
        # is declared is a fitting place (scope) at which to mark a point of
        # shared memoization of the edit session. by doing this, tests that
        # want access to the edit session directly (for example to assert
        # output) will use *the same* e.s that is was or will be used to
        # produce the context lines (memoized #here).

        yes = true ; x = nil
        define_method :shared_edit_session_for_context_lines do
          if yes
            yes = false
            x = instance_exec( & p )
          end
          x
        end ; nil
      end

      def shared_context_lines  # #here

        # sadly we must put thought into where calls to this method belong

        yes = true ; x = nil
        define_method :_CL_tuple do
          if yes
            yes = false
            x = __CL_build_tuple
          end
          x
        end ; nil
      end
    end

    module Instance_Methods___

      # -- for compat with lower-level test lib nodes

      def mutated_edit_session_
        shared_edit_session_for_context_lines
      end

      # --

      def want_paragraph_for_context_stream_ st, & p
        @context_stream = st
        instance_exec( & p )
        remove_instance_variable :@context_stream
      end

      def _ s_content  # only access this thru the above method.

        act_tl = @context_stream.gets
        if act_tl
          act_s = act_tl.to_unstyled_bytes_string_
          act_s.chomp!
          if act_s != s_content
            expect( act_s ).to eql s_content
          end
        else
          fail ___CL_say_etc s_content
        end
      end

      def ___CL_say_etc s
        "had no more lines in section. expected line content: #{ s.inspect }"
      end

      def for_context_stream_ st
        @context_stream = st ; nil
      end

      def before_throughput_line_stream_
        _CL_tuple.fetch 0
      end

      def during_throughput_line_stream_
        _CL_tuple.fetch 1
      end

      def after_throughput_line_stream_
        _CL_tuple.fetch 2
      end

      def for_first_and_only_line_
        st = _remove_context_stream
        tl = st.gets
        tl or fail
        st.gets and fail
        for_context_line_ tl
      end

      def for_context_line_ tl
        begin_want_atoms_for_ tl.a ; nil
      end

      def want_no_lines_in_ st
        st.gets and fail
      end

      def _remove_context_stream
        remove_instance_variable :@context_stream
      end

      def __CL_build_tuple

        _edit_session = shared_edit_session_for_context_lines

        _bef = _CL_num_lines_before
        _aft = _CL_num_lines_after
        _match_d = _CL_match_controller_index

        _match_controller = _Nth_match_controller _match_d, _edit_session

        _match_controller.to_contexted_throughput_line_streams_ _bef, _aft
      end

      _ = [ :LTS_begin, "\n", :LTS_end ]

      define_method :_NL do
        _
      end
    end
  end
end
# #history: splintered
