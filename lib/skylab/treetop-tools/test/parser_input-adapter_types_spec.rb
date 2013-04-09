require_relative 'test-support'

# Quickie!

describe "#{ ::Skylab::TreetopTools::Parser::InputAdapter::Types }" do

  TreetopTools = ::Skylab::TreetopTools

  it "does semantic digraph thing" do
    o = TreetopTools::Parser::InputAdapter::Types
    o::STREAM.is?( o::STREAM ).should eql( true  )
    o::FILE.is?(   o::STREAM ).should eql( true  )
    o::STREAM.is?( o::FILE   ).should eql( false )
    o::STRING.is?( o::STREAM ).should eql( false )
  end
end
