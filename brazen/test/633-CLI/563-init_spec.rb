require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI (actions) init" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_actions

    with_invocation 'init', '.'
    with_max_num_dirs_ '1'

    context "from within empty directory ( NOTE misspelling in preterite :P )" do

      from_new_directory_one_deep

      shared_subject :state_ do
        line_oriented_state_from_invoke
      end

      it "succeeds" do  # :#cov1.3
        results_in_success_exitstatus_
      end

      it "says inited (sic)" do

        _rx = %r(\Ainited workspace: created \./brazen\.conf .+bytes)
        first_line.should match_ expectation _rx
      end

      it "says config filename" do

        second_line.should match_ expectation " config filename: brazen.conf"
      end

      it "says surrounding path" do

        last_line.should match_ expectation "surrounding path: ."
      end
    end

    context "from within directory that already has a file" do

      from_directory_with_already_a_file

      shared_subject :state_ do
        line_oriented_state_from_invoke
      end

      it "fails" do
        results_in_error_exitstatus_
      end

      it "whines" do
        _rx = %r(<path> already has config file - \./#{ ::Regexp.escape cfg_filename })
        first_line.should match_ expectation( :styled, _rx )
      end

      it "not more than 2 lines about this" do
        ( 1..2 ).should be_include state_.number_of_lines
      end
    end
  end
end
