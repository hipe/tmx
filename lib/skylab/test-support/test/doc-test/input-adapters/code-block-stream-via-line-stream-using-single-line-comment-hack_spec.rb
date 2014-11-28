require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest::Input

  describe "[ts] doc-test - input adapters" do

    extend TS_

    with_big_file_path do
      TestSupport_.dir_pathname.join( 'doc/issues/015-the-doc-test-narrative.md' ).to_path
    end

    with_magic_line %r(\A[ ]{4,}this is some code$)

    it "file one has two comment blocks" do
      with_file :file_one
      expect_comment_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 1
      expect_no_more_comment_blocks
    end

    it "file two has three comment blocks" do
      with_file :file_two
      expect_comment_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 2
      expect_comment_block_with_number_of_lines 3
      expect_no_more_comment_blocks
    end

    it "file three has two comment blocks" do
      with_file :file_three
      expect_comment_block_with_number_of_lines 1
      expect_comment_block_with_number_of_lines 1
      expect_no_more_comment_blocks
    end

    it "file four has three comment blocks" do
      with_file :file_four
      expect_comment_block_with_number_of_lines 3
      expect_no_more_comment_blocks
    end
  end
end
