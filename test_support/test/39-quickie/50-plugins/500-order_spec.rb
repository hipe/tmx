require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - order" do

    TS_[ self ]
    use :quickie_plugins

    # - context - bad argument

      # - API

        it "API - bad argument - whines" do

          call :order, 'fetty'
          expect :error, :expression, :primary_parse_error do |y|
            y == [ "expecting <digit> or \"N\" for \"fetty\"" ] || fail
          end
          expect_fail
        end
      # -
    # -

    # - context - help

      it "CLI - help - can (~50-60 lines)" do

        invoke "-order", "help"
        on_stream :serr
        count = 0
        expect_each_by do |line|
          count += 1
          NIL
        end
        expect_succeed
        ( 50 .. 60 ).include? count or fail
      end

      it "API - help - can't" do

        call :order, 'help'
        expect :error, :expression, :mode_mismatch do |y|
          y == [ "no 'help' for API client" ] || fail
        end
        expect_fail
      end
    # -

    # - context - FETTY

    context "(hacking the original stream of files)" do

      # - API

        it "API - order yes" do

          call :order, '1-N', :list_files, :path, 'mock-key-1'

          _use_fake_paths 'mock-key-1' do |y|
            y << 'fake-path/030-jumanji/040-chim-chum.xx'
            y << 'fake-path/010-herkemer/020-xx.xx'
            y << 'fake-path/030-jumanji/010-yy.xx'
          end

          _these = finish_by do |st|
            st.to_a
          end

          expect_these_lines_in_array_ _these do |y|
            y << "fake-path/010-herkemer/020-xx.xx"
            y << "fake-path/030-jumanji/010-yy.xx"
            y << "fake-path/030-jumanji/040-chim-chum.xx"
          end
        end

        it "API - overflow is not OK" do

          call :order, '1-4', :list_files, :path, 'mock-key-1'

          _use_fake_paths 'mock-key-1' do |y|
            y << 123  # while it works..
            y << 456
            y << 789
          end

          expect :error, :expression, :primary_parse_error do |y|
            y == [ "second term cannot be greater than 3. (had 4.)" ] || fail
          end

          expect_fail
        end

        def prepare_subject_API_invocation invo
          _prepare_subject_API_invocation_for_fake_paths invo
        end
      # -
    end

    # ==

    def _use_fake_paths mock_key
      @THESE_FAKE_PATHS = yield []
      @MOCK_KEY = mock_key ; nil
    end

    def _prepare_subject_API_invocation_for_fake_paths invo

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

    # ==
  end
end
# #born years later
