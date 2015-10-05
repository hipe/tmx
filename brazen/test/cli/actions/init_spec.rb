require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  describe "[br] CLI actions init" do

    extend TS_

    with_invocation 'init', '.'
    with_max_num_dirs_ '1'

    context "from within empty directory ( NOTE misspelling in preterite :P )" do

      from_new_directory_one_deep

      it "ok, inits." do
        invoke
        expect %r(\Ainited a workspace: created \./brazen\.conf .+bytes)
        expect " config filename: brazen.conf"
        expect "surrounding path: ."
        expect_succeeded
      end
    end

    context "from within directory that already has a file" do

      from_directory_with_already_a_file

      it "whines" do
        invoke
        expect :styled, %r(<path> already has config file - \./#{ ::Regexp.escape cfg_filename })
        expect_generic_error_exitstatus
      end
    end
  end
end