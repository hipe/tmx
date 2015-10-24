require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  describe "[st] models - file-coverage - 01: find the test directory" do

    extend TS_
    use :expect_event

    it "against an asset file when the root dir is not found" do

      where do
        the_asset_file
        max_num_dirs 0
      end

      expect_not_OK_event :resource_not_found do | ev |
        ev_ = ev.to_event
        ev_.start_path.should eql the_asset_file_path
        ev_.num_dirs_looked.should be_zero
        ev_.file_pattern_x.should be_respond_to :each_with_index
        ev_.ok.should eql false
      end

      expect_failed
    end

    it "against a test file when the root dir is not found" do

      where do
        the_test_file
        max_num_dirs 0
      end

      expect_not_OK_event :resource_not_found
      expect_failed
    end

    it "against an asset file when the root dir is found" do

      where do
        the_asset_file
        max_num_dirs 2
      end

      expect_that_the_root_is_found
    end

    it "against a test file when the root dir is found" do

      where do
        the_test_file
        max_num_dirs 2
      end

      expect_that_the_root_is_found
    end

    it "on the root dir itself - root is found" do

      where do
        path fixture_tree( :one )
        max_num_dirs 1
      end

      expect_that_the_root_is_found
    end

    it "on the test dir itself - root is found" do

      where do
        path "#{ fixture_tree :one }/test"
        max_num_dirs 1
      end

      expect_that_the_root_is_found
    end

    # ~ test setup & asset execution

    def the_asset_file
      path the_asset_file_path
    end

    let :the_asset_file_path do
      "#{ fixture_tree :one }/foo.rb"
    end

    def the_test_file
      path the_test_file_path
    end

    let :the_test_file_path do
      "#{ fixture_tree :one }/test/foo_speg.rb"
    end

    check = -> unb do
      check = nil
      unb.is_branch and fail  # assert the firs ever [#br-013]:API.B
    end

    define_method :where do | & sess |

      unb = Home_::API.application_kernel_.silo( :file_coverage ).unbound

      check and check[ unb ]

      bnd = unb.new Kernel_stub_[] , & handle_event_selectively

      bnd.instance_variable_set :@nc, Name_conventions_[]
      bnd.instance_variable_set :@be_verbose, false
      @__bound__ = bnd
      sess[]
      @result = bnd.__find_the_test_directory
      NIL_
    end

    def path path
      @__bound__.instance_variable_set :@path, path
      NIL_
    end

    def max_num_dirs d
      @__bound__.instance_variable_set :@max_num_dirs, d
      NIL_
    end

    # ~ test assertion

    def expect_that_the_root_is_found

      _s = @__bound__.instance_variable_get( :@test_dir )
      TEST__ == _s[ - TEST__.length .. -1 ] or fail
      expect_succeeded
    end
  end
end
