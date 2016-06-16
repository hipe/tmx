require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - BS via LS and SLCH" do

    TS_[ self ]
    use :files

    with_big_file_path do
      special_file_path_ :the_readme_document
    end

    with_magic_line %r(\A[ ]{4,}this is some code$)

    it "file one has two comment blocks" do
      with_file :file_one
      expect_static_block_with_number_of_lines 2
      expect_comment_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 1
      expect_static_block_with_number_of_lines 2  # #eesh
      expect_no_more_blocks
    end

    it "file two has three comment blocks" do
      with_file :file_two
      expect_static_block_with_number_of_lines 2
      expect_comment_block_with_number_of_lines 1
      expect_static_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 2
      expect_static_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 3
      _expect_common_finish
    end

    it "file three has two comment blocks" do
      with_file :file_three
      expect_static_block_with_number_of_lines 2
      expect_comment_block_with_number_of_lines 1
      expect_static_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 1
      _expect_common_finish
    end

    it "file four has three comment blocks" do
      with_file :file_four
      expect_static_block_with_number_of_lines 2
      expect_comment_block_with_number_of_lines 3
      _expect_common_finish
    end

    def _expect_common_finish
      expect_static_block_with_number_of_lines 3  # #eesh
      expect_no_more_blocks
    end
  end
end
# #history: a rename-and-edit of "comment block stream via [same]"
