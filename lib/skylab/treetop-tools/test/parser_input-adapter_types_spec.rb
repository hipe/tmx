require_relative 'test-support'

# Quickie!

describe "[ttt] parser input adapter types" do

  it "does semantic digraph thing" do
    o = ::Skylab::TreetopTools::Parser::InputAdapter::Types
    o::STREAM.is?( o::STREAM ).should eql( true  )
    o::FILE.is?(   o::STREAM ).should eql( true  )
    o::STREAM.is?( o::FILE   ).should eql( false )
    o::STRING.is?( o::STREAM ).should eql( false )
  end
end
