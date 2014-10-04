require_relative 'test-support'

module Skylab::Headless::TestSupport::IO::Interceptors

  describe "[hl] IO interceptors filter" do

    context "without a line boundary event handler" do

      it "leaves brittany alone" do
        downstream = ::StringIO.new
        stream = Headless_::IO::Interceptors::Filter.new(downstream)
        stream.write('a')
        downstream.string.should eql('a')
        stream.puts('b')
        downstream.string.should eql("ab\n")
      end
    end

    context "with a line boundary event handler" do
      let(:downstream) { ::StringIO.new }
      let(:stream) do
        o = Headless_::IO::Interceptors::Filter.new(
          :downstream_IO, downstream,
          :line_begin_proc, -> do
            o.downstream_IO.write 'Z '
          end )
      end
      def self.assert input, output, *tags
        it("#{input.inspect} becomes #{output.inspect}", *tags) do
          stream.write input
          downstream.string.should eql(output)
        end
      end
      assert '', ''
      assert 'a', 'Z a'
      assert "a\n", "Z a\n"
      assert "\na", "Z \nZ a"
      assert "a\nb", "Z a\nZ b"
      assert "\nabc\ndef\n\nghi", "Z \nZ abc\nZ def\nZ \nZ ghi"
      it 'write("a") ; puts("b") ; puts("c") works' do
        stream.write('a')
        downstream.string.should eql('Z a')
        stream.puts('b')
        downstream.string.should eql("Z ab\n")
        stream.puts('c')
        downstream.string.should eql("Z ab\nZ c\n")
      end
      it 'write("ab") ; write("cd\nef") works' do
        stream.write('ab')
        downstream.string.should eql('Z ab')
        stream.write("cd\nef")
        downstream.string.should eql("Z abcd\nZ ef")
      end
    end

    context "with a puts filter" do
      it "works with one filter" do
        downstream = ::StringIO.new
        stream = Headless_::IO::Interceptors::Filter.new(
          :downstream_IO, downstream,
          :puts_map_proc, -> x do
            "  << epic: #{ x } >>\n"
          end )
        stream.write 'a'
        downstream.string.should eql( 'a' )
        stream.puts( 'bcd' )
        downstream.string.should eql( "a  << epic: bcd >>\n" )
      end
    end
  end
end
