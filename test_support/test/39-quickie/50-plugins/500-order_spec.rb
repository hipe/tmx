require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - order" do

    TS_[ self ]
    use :quickie_plugins

    # - context - bad argument

      # - API

        it "API - bad argument - whines" do

          call :order, 'fetty'
          want :error, :expression, :primary_parse_error do |y|
            y == [ "expecting <digit> or \"N\" for \"fetty\"" ] || fail
          end
          want_fail
        end
      # -
    # -

    # - context - help

      it "CLI - help - can (~50-60 lines)" do

        invoke "-order", "help"
        on_stream :serr
        count = 0
        want_each_by do |line|
          count += 1
          NIL
        end
        want_succeed
        ( 50 .. 60 ).include? count or fail
      end

      it "API - help - can't" do

        call :order, 'help'
        want :error, :expression, :mode_mismatch do |y|
          y == [ "no 'help' for API client" ] || fail
        end
        want_fail
      end
    # -

    # - context - FETTY

    context "(hacking the original stream of files)" do

      # - API

        it "API - order yes" do

          call :order, '1-N', :list_files, :path, 'mock-key-1'

          use_fake_paths_ 'mock-key-1' do |y|
            y << 'fake-path/030-jumanji/040-chim-chum.xx'
            y << 'fake-path/010-herkemer/020-xx.xx'
            y << 'fake-path/030-jumanji/010-yy.xx'
          end

          _these = finish_by do |st|
            st.to_a
          end

          want_these_lines_in_array _these do |y|
            y << "fake-path/010-herkemer/020-xx.xx"
            y << "fake-path/030-jumanji/010-yy.xx"
            y << "fake-path/030-jumanji/040-chim-chum.xx"
          end
        end

        it "API - overflow is not OK" do

          call :order, '1-4', :list_files, :path, 'mock-key-1'

          use_fake_paths_ 'mock-key-1' do |y|
            y << 123  # while it works..
            y << 456
            y << 789
          end

          want :error, :expression, :primary_parse_error do |y|
            y == [ "second term cannot be greater than 3. (had 4.)" ] || fail
          end

          want_fail
        end

        def prepare_subject_API_invocation invo
          prepare_subject_API_invocation_for_fake_paths_ invo
        end
      # -
    end

    # ==

    # ==
  end
end
# #born years later
