require_relative '../../../..' # skylab.rb
require_relative '../../../io/interceptors/filter'
require 'stringio'
require 'skylab/test-support/quickie'


module Skylab::Headless::IO::Interceptors::TestSupport
  Headless = ::Skylab::Headless
  extend ::Skylab::TestSupport::Quickie::ModuleMethods
  describe "#{::Skylab::Headless::IO::Interceptors::Filter}" do
    context "without a line boundary event handler" do
      it "leaves brittany alone" do
        downstream = ::StringIO.new
        stream = Headless::IO::Interceptors::Filter.new(downstream)
        stream.write('a')
        downstream.string.should eql('a')
        stream.puts('b')
        downstream.string.should eql("ab\n")
      end
    end
    context "witha a line boundary event handler" do
      it "filtering works" do
        downstream = ::StringIO.new
        stream = Headless::IO::Interceptors::Filter.new(downstream) do |f|
          f.on_line_boundary { f.downstream.write("ZERK ") }
        end
        stream.write('a')
        downstream.string.should eql('ZERK a')
        stream.puts('b')
        downstream.string.should eql("ZERK ab\n")
        stream.puts('c')
        downstream.string.should eql("ZERK ab\nZERK c\n")
      end
    end
  end
end
