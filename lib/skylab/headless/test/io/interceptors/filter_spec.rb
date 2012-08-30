require_relative 'test-support'

module Skylab::Headless::IO::Interceptors::TestSupport
  Headless = ::Skylab::Headless
  # extend ::Skylab::TestSupport::Quickie::ModuleMethods
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
    context "with a line boundary event handler" do
      let(:downstream) { ::StringIO.new }
      let(:stream) do
        Headless::IO::Interceptors::Filter.new(downstream) do |f|
          f.on_line_boundary { f.downstream.write("Z ") }
        end
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
  end
end
