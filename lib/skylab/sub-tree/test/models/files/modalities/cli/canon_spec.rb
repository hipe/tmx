require_relative '../../test-support'  # change-this-at-step:10 and below

module Skylab::SubTree::TestSupport

  describe "[st] CLI actions my-tree", wip: true do

    extend TS_

    _PN = 'xyzzy2'

    _FULL_PN = 'meh' # = ( [ _PN, * TS_::SUT_CMD_SETTING_.value ] * ' ' ).freeze

    _INVITE_RX = /\ATry #{ _FULL_PN } -h for help\.\z/i

    _USAGE_RX = /\Ausage: #{ _FULL_PN }.* \[-f <file\>\] .*#{
      }\[<path> \[<path>\[\.\.\.\]\]\]\z/

    it "1.2 : one unrec opt : msg / usage / invite" do
      result = invoke '-x'
      nonstyled.should match(/\Ainvalid option: -x\z/)
      styled.should match _USAGE_RX
      styled.should match _INVITE_RX
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

    _OPT_SUMMARY_FIRST_LINE_RX =
      /\A[ ]{3,}-[a-zA-Z], --(?:(?!>  ).)+[^ ][ ]{2,}[^ ]/  # ensure some desc

    def expect_beautiful_help
      styled.should match _USAGE_RX
      any_blanks
      header 'description'
      nonstyled.should match( /\A[ ].+\binspired\b.+\btree\b/i )
      nonstyled.should match( /\A[ ]+[a-z ]{10,}\z/ )
      any_blanks
      header 'options'
      one_or_more_styled _OPT_SUMMARY_FIRST_LINE_RX
      any_blanks
      styled.should match( /add.+volume/ )
      styled.should match( /it can also read paths from STDIN/ )
      styled.should match( /this screen/ )
      no_more_lines
    end
  end
end
