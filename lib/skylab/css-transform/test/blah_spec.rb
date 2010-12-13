require File.expand_path('../../lib/css-convert', __FILE__)
require 'fileutils'
require 'stringio'

module Hipe::CssConvert::ExampleHelperMethods
  def new_cli
    Hipe::CssConvert.cli.buffered!
  end
  def fixture tail
    File.join('spec/fixtorros', tail)
  end
end

module BlahSpec
  describe Hipe::CssConvert::Cli do
    include Hipe::CssConvert::ExampleHelperMethods
    it "should give helpful message with no error" do
      c = new_cli
      c.run([]).should == 1
      c.out.flush.should match(/^Usage: ([^ ]+) \[file\]$/)
    end
    it "should give helpful message with too many args" do
      c = new_cli
      c.run(['a', 'b']).should == 1
      c.out.flush.should match(/^Usage: ([^ ]+) \[file\]$/)
    end
    it "should whine about file not found" do
      c = new_cli
      c.run([fixture('not-there.txt')]).should == 1
      s = c.err.flush
      s.should == "File not found: spec/fixtorros/not-there.txt\n"
    end
  end
end