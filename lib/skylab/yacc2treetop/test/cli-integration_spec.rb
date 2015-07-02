require_relative 'test-support'

module Skylab::Yacc2Treetop::TestSupport::CLI

  include InstanceMethods  # for constants (1.9.2 to 1.9.3)
# ..

describe "[y2] CLI integration" do

  extend ::Skylab::Yacc2Treetop::TestSupport::CLI

  self::Home_ = ::Skylab::Yacc2Treetop

  context 'doing nothing' do
    invoke
    it 'writes specific complaint, usage, invite to stderr' do
      out.length.should eql(0)
      err.shift.should match(/missing <yaccfile> argument/i)
      unstyle(err.shift).should match(USAGE_RX)
      unstyle(err.shift).should match(INVITE_RX)
      err.length.should eql(0)
    end
  end

  context 'asking for help' do
    invoke '-h'
    it 'writes usage, option listing to stderr' do
      out.length.should eql(0)
      unstyle(err.shift).should match(USAGE_RX)
      (5..15).should be_include err.length
      err.last.should match(/\A    [ ]*[^ ]/) # any option listing
    end
  end

  context 'giving 2 args' do
    invoke 'one', 'two'
    it "writes specific complaint, usage, invite to stderr" do
      out.length.should eql(0)
      err.shift.should match(/\btoo many args\. +expecting 1 .*file/i)
      unstyle(err.shift).should match(USAGE_RX)
      unstyle(err.shift).should match(INVITE_RX)
      err.length.should eql(0)
    end
  end

  context 'giving it a nonexistant filename' do
    invoke 'not-there.yacc'
    it 'writes specific complaint, usage, invite to stderr' do
      out.length.should eql(0)
      err.shift.should match(/file.+not found.+not-there\.yacc/i)
      unstyle(err.shift).should match(USAGE_RX)
      unstyle(err.shift).should match(INVITE_RX)
      err.length.should eql(0)
    end
  end

  context 'giving it a good filename' do
    invoke self::FIXTURES.join('060.choice-parse.y3').to_s
    it 'writes a treetop grammar to stdout' do
      err.length.should eql(0)
      (4..4).should be_include out.length
      out.first.should eql('( type_selector / universal )')
    end
  end
end
# ..
end
