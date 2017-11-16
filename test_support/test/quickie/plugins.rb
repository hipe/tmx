module Skylab::TestSupport::TestSupport

  module Quickie

    module Plugins

      def self.[] tcc
        Zerk_test_support_[]::Want_CLI_or_API[ self ]
        tcc.include self
      end


        def write_messages_into_for_no_transition_because_nothing_pending_ y

          y << "there are no state transitions so #{
            }nothing brings the system from the beginning state to a finished state."
        end

        def write_messages_into_for_invite_generically_ y
          y << "see 'quee -h' for help."
        end

        def messages_via_no_transition_found_
          messages_via_want_fail :error, :expression, :no_transition_found
        end

        def want_these_lines_via_no_transition_found_ & p
          want_these_lines_via_want_fail :error, :expression, :no_transition_found, & p
        end

        def use_fake_paths_ mock_key
          @THESE_FAKE_PATHS = yield []
          @MOCK_KEY = mock_key ; nil
        end

        def prepare_subject_API_invocation_for_fake_paths_ invo

          fake_paths = remove_instance_variable :@THESE_FAKE_PATHS
          mock_key = remove_instance_variable :@MOCK_KEY

          _msvc = invo.instance_variable_get :@__tree_runner_microservice
          _pi = _msvc.DEREFERENCE_PLUGIN :path
          _pi.send :define_singleton_method, :__to_test_file_path_stream do

            _s_a = remove_instance_variable :@_mixed_path_arguments  # implicit assertion of once
            _s_a == [ mock_key ] || TS_._SANITY
            Home_::Stream_[ fake_paths ]
          end

          invo
        end

        def hack_that_one_plugin_of_invocation_to_use_this_runtime_ invo, & p

          # touch the particular plugin "early" and hack this one method on it

          _msvc = invo.instance_variable_get :@__tree_runner_microservice

          pi = _msvc.DEREFERENCE_PLUGIN :run_files

          once = -> do # assert that it's only called once just because
            rt = p[]
            once = nil
            rt
          end

          pi.send :define_singleton_method, :__quickie_runtime do
            once[]
          end

          pi
        end

        def build_fresh_dummy_runtime_

          # don't read from or write to the real life production runtime

          Home_::Quickie::Runtime___.define do |o|
            o.kernel_module = :_no_see_ts_
            o.toplevel_module = :_no_see_ts_
          end
        end

        # -- officious

        def prepare_subject_CLI_invocation invo
          NOTHING_
        end
        #
        def program_name_string_array
          PNSA___
        end
        PNSA___ = %w( ts quee )
        #
        def subject_CLI
          Home_::Quickie::API::CLI_for_RecursiveRunner
        end

        def prepare_subject_API_invocation invo
          invo
        end
        #
        def subject_API
          Home_::Quickie::API  # <-
        end
      # -

      # ==

      class DescribeProxy  # 1x
        def initialize & p
          @__once = p
        end
        def describe * s_a, & p
          remove_instance_variable( :@__once )[ p, s_a ]
        end
      end

      # ==

      # ==
    end
  end
end
# #tombstone-A: the birthcode of "hybrid" CLI & API
# #born as [ts] quickie plugins test support node; first ever hybrid CLI/API support
