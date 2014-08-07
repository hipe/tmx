require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  describe "[br] CLI actions init" do

    extend TS_

    with_sub_action 'init'
    with_max_num_dirs '1'

    context "from within empty directory" do
      from_new_directory_one_deep
      it "ok, inits."
    end

    context "from within directory that already has a file" do
      from_directory_with_already_a_file
      it "whines" do
        invoke
        expect :styled, "<path> already has config file - ./#{ filename }"
        expect_negative_exitstatus
      end
    end
  end
end
