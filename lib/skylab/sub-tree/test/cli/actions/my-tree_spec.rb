require_relative 'my-tree/test-support'

module Skylab::SubTree::TestSupport::CLI::Actions::My_Tree

  describe "[st] CLI actions my-tree" do

    extend TS_

    FULL_PN_ = ( [ PN_, * TS_::SUT_CMD_SETTING_.value ] * ' ' ).freeze

    INVITE_RX_ = /\ATry #{ FULL_PN_ } -h for help\.\z/i

    USAGE_RX_ = /\Ausage: #{ FULL_PN_ }.* \[-f <file\>\] .*#{
      }\[<path> \[<path>\[\.\.\.\]\]\]\z/

    it "1.2 : one unrec opt : msg / usage / invite" do
      result = invoke '-x'
      nonstyled.should match(/\Ainvalid option: -x\z/)
      styled.should match USAGE_RX_
      styled.should match INVITE_RX_
      no_more_lines
      result.should eql 1
    end

    it "1.4 one rec opt : -h (as prefix) - beautiful help screen" do
      cmd_a = '-h', "#{ TS_::SUT_CMD_SETTING_.value * ' ' }"
      r = super_invoke( * cmd_a )
      expect_beautiful_help
      r.should be_zero
    end

    it "1.4 one rec opt : -h (as postfix) - beautiful help screen" do
      r = invoke '-h'
      expect_beautiful_help
      r.should be_zero
    end

    OPT_SUMMARY_FIRST_LINE_RX_ =
      /\A[ ]{3,}-[a-zA-Z], --(?:(?!>  ).)+[^ ][ ]{2,}[^ ]/  # ensure some desc

    def expect_beautiful_help
      styled.should match USAGE_RX_
      any_blanks
      header 'description'
      nonstyled.should match( /\A[ ].+\binspired\b.+\btree\b/i )
      nonstyled.should match( /\A[ ]+[a-z ]{10,}\z/ )
      any_blanks
      header 'options'
      one_or_more_styled OPT_SUMMARY_FIRST_LINE_RX_
      any_blanks
      styled.should match( /add.+volume/ )
      styled.should match( /it can also read paths from STDIN/ )
      styled.should match( /this screen/ )
      no_more_lines
    end
  end
end
