require_relative '../../../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] models - file-coverage - 02: classify the path" do

    TS_[ self ]
    use :expect_event
    use :models_file_coverage

    it "path does not exist" do

      where do
        test_dir_is_test_dir_one
        @path = "#{ fixture_tree :one }/i-dont-exist.file"
      end

      expect_not_OK_event :resource_not_found do | ev |

        ::File.basename( ev.path ).should eql 'i-dont-exist.file'
      end
      expect_failed
    end

    it "path is a test file" do

      where do
        test_dir_is_test_dir_one
        @path = "#{ fixture_tree :one }/test/foo_speg.rb"
      end

      expect :test, :file
    end

    it "path is an asset file" do

      where do
        test_dir_is_test_dir_one
        @path = "#{ fixture_tree :one }/foo.rb"
      end

      expect :asset, :file
    end

    it "path is a non-root test directory" do

      where do
        test_dir_is_test_dir_two
        @path = "#{ fixture_tree :two }/test/dir-A"
      end

      expect :test, :directory, :non_root
    end

    it "path is a non-root asset directory" do

      where do
        test_dir_is_test_dir_two
        @path = "#{ fixture_tree :two }/dir-A-"
      end

      expect :asset, :directory, :non_root
    end

    it "path is the root test directory" do

      where do
        test_dir_is_test_dir_one
        @path = "#{ fixture_tree :one }/test"
      end

      expect :test, :directory, :root
    end

    it "path is the root asset directory" do

      where do
        test_dir_is_test_dir_one
        @path = fixture_tree :one
      end

      expect :asset, :directory, :root
    end

    def test_dir_is_test_dir_one
      @test_dir = "#{ fixture_tree :one }/test"
      nil
    end

    def test_dir_is_test_dir_two
      @test_dir = "#{ fixture_tree :two }/test"
      nil
    end

    def where
      yield
      @result = subject_::Actors_::Classify_the_path[
        @test_dir, @path, & handle_event_selectively_ ]
      NIL_
    end

    def expect testiness_symbol, shape_symbol, rootiness_symbol=nil

      if @result

        x = @result.difference_against testiness_symbol, shape_symbol, rootiness_symbol
        x and fail x.description
        expect_no_events
      else
        fail "expected result, had none"
      end

    end
  end
end
