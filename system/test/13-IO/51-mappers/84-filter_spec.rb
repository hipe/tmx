require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] IO - mappers - filter" do

    TS_[ self ]
    use :the_method_called_let

    context "without a line boundary event handler" do

      it "leaves brittany alone" do
        downstream = ::StringIO.new
        stream = Home_::IO::Mappers::Filter[ downstream ]
        stream.write('a')
        expect( downstream.string ).to eql('a')
        stream.puts('b')
        expect( downstream.string ).to eql("ab\n")
      end
    end

    context "with a line boundary event handler" do
      let(:downstream) { ::StringIO.new }
      let(:stream) do
        o = Home_::IO::Mappers::Filter.with(
          :downstream_IO, downstream,
          :line_begin_proc, -> do
            o.downstream_IO.write 'Z '
          end )
      end
      def self.assert input, output, *tags
        it("#{input.inspect} becomes #{output.inspect}", *tags) do
          stream.write input
          expect( downstream.string ).to eql(output)
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
        expect( downstream.string ).to eql('Z a')
        stream.puts('b')
        expect( downstream.string ).to eql("Z ab\n")
        stream.puts('c')
        expect( downstream.string ).to eql("Z ab\nZ c\n")
      end
      it 'write("ab") ; write("cd\nef") works' do
        stream.write('ab')
        expect( downstream.string ).to eql('Z ab')
        stream.write("cd\nef")
        expect( downstream.string ).to eql("Z abcd\nZ ef")
      end
    end

    context "with a puts filter" do
      it "works with one filter" do
        downstream = ::StringIO.new
        stream = Home_::IO::Mappers::Filter.with(
          :downstream_IO, downstream,
          :puts_map_proc, -> x do
            "  << epic: #{ x } >>\n"
          end )
        stream.write 'a'
        expect( downstream.string ).to eql( 'a' )
        stream.puts( 'bcd' )
        expect( downstream.string ).to eql( "a  << epic: bcd >>\n" )
      end
    end

    before :all do
      Home_.lib_.string_IO
    end
  end
end
