require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - list-files" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie_plugins

    context "no args" do

      # :#coverpoint-2-1: no args will always fail, right?

      # - API

        it "fails on this channel" do
          messages_ || fail
        end

        it "whines obscurely that it doesn't reach a finished state" do

          fails_with_these_messages_ do |y|
            y << "there are no pending executions"
            y << "so nothing brings the system from the beginning state to #{
              }a finished state"
          end
        end

        shared_subject :messages_ do
          call
          expect_no_transition_found_
        end
      # -
    end

    # ==

    context "list files with no other arg" do

      # - API

        it "fails on this channel" do
          messages_ || fail
        end

        it "whines obscurely that it doesn't reach a finished state" do

          fails_with_these_messages_ do |y|

            y << "the only pending execution does not bring #{
              }the system from the beginning state to a finished state"
          end
        end

        shared_subject :messages_ do
          call :list_files
          expect_no_transition_found_
        end
      # -
    end

    # ==

    context "list files with strange primary" do

      # - API

        it "primary parse error" do
          messages_ || fail
        end

        it "lists available primaries" do
          fails_with_these_messages_ do |y|
            y << "unknown primary 'jajoomba'"
            y << %r(\Aavailable primaries: ')
          end
        end

        shared_subject :messages_ do
          call :list_files, :jajoomba
          expect_primary_parse_error_
        end
      # -
    end

    # ==

    path = :path

    # ==

    it "when argument value is false, bespoke message" do

      #coverpoint [#039.2] lending coverage to: [ze]

      call path, FALSE

      _msgs = expect_primary_parse_error_

      _msgs == ["'path' must be trueish (had false)"] || fail
    end

    context "no ent dir" do

      # - API

        it "still results in stream (the empty stream)" do

          # #coverpoint-2-3: no longer do we break the stream in these cases

          binding_.local_variable_get( :_items ).length.zero? || fail
        end

        it "whines about no-ent" do

          y = binding_.local_variable_get :messages
          1 == y.length || fail
          y[0].include? "no *_spec.rb files in directory or no directory" or fail
        end

        shared_subject :binding_ do

          _no_ent_dir = Home_::Fixtures.directory :not_here

          call :list_files, path, _no_ent_dir

          messages = nil
          expect :warning, :expression, :no_ent do |y|
            messages = y
          end

          _items = finish_by do |st|
            st.to_a
          end

          binding
        end
      # -
    end

    # ==

    eek = __FILE__
    dir = ::File.dirname eek

    # - context
      # - API
        it "API - yay - find self as a test file. no emissions, just stream of file" do

          call :list_files, path, dir

          _a = finish_by do |st|
            st.to_a
          end

          _a.include? eek or fail
        end
      # -
    # -

    # - context
      # - CLI
        it "CLI - just this one file - writes one line to stdout" do

          invoke '-path', eek, '-list-files'
          expect_on_stdout eek
          expect_succeed
        end
      # -
    # -

    # - context
      # - API

        it "API - multiple directories!" do

          # :#quickie-spot-2-1 (assume a certain test subtree)

          eek_ = TS_.dir_path
          _one = ::File.join eek_, '20-magnetics'
          _two = ::File.join eek_, '30-io-spy'  # name :(

          call :list_files, :path, _one, :path, _two

          a = finish_by do |st|
            st.to_a
          end

          a.first.ascii_only?  # assert that it is a string

          ( 3..4 ).include? a.length or fial
        end
      # -
    # -

    # ==

    def expect_primary_parse_error_
      messages_from_expect_for_API_ :error, :expression, :primary_parse_error
    end

    # ==

    # :[#039.1]: lending coverage to [ze]: different code is used depending
    # on whether you are dereferencing a plugin for the first time or one
    # whose class-ish node is already loaded. there is no dedicated coverage
    # to dereferencing a plugin a non-first time, but that is covered
    # incidentally by running more than one of the test cases in this file
    # (same operator, different invocations).

  end
end
# #born years later, as first integrated example of new eventpoint pathfinding
