require File.expand_path('../../table', __FILE__)
require File.expand_path('../test-support', __FILE__)

module Skylab::Porcelain::TestSupport
  include Skylab
  describe Porcelain::Table do
    let(:subject) { Porcelain }
    let(:_stdout) { StringIO.new }
    let(:stdout) { _stdout.string }
    context Porcelain::Table do
      specify { should be_const_defined(:Table) }
      specify { should be_respond_to(:table) }
    end
    context "rendering tables" do
      it "renders the empty table" do
        r = Porcelain.table([]) { |o| o.on_all { |e| _stdout.puts e } }
        stdout.should eql("(empty)\n")
        r.should eql(nil)
      end
      it "you can also just get a string back" do
        Porcelain.table([]).should eql("(empty)\n")
      end
      it "renders a 2 x 2 table (align left)" do
        data = [ %w(derp mcderperson),
                 %w(herper mcderpertino) ]
        Porcelain.table(data).should eql(<<-HERE.unindent)
          derp   mcderperson 
          herper mcderpertino
        HERE
      end
      it "takes options the canonical way" do
        s = Porcelain.table([['a','b'],['c','dd']], :head => '<<', :tail => '>>', :separator => ' | ')
        s.should eql(<<-HERE.unindent)
          <<a | b >>
          <<c | dd>>
        HERE
      end
      it "takes options also in the block with the event knob" do
        Porcelain.table([['a','b'],['c','dd']]) do |o|
          o.head = '<<' ; o.tail = '>>' ; o.separator = ' | '
          o.on_all { |e| _stdout.puts e }
        end
        stdout.should eql(<<-HERE.unindent)
          <<a | b >>
          <<c | dd>>
        HERE
      end
    end
    context 'infers types of columns and renders accordingly' do
      let(:rendered_table) { Porcelain.table(row_enum) }
      context 'with some everyday ordinary strings' do
        let(:row_enum) do
          [['meep', 'mop'],
           ['pee',  'poo']]
        end
        it 'will align left' do
          rendered_table.should eql(<<-HERE.unindent)
            meep mop
            pee  poo
          HERE
        end
      end
      context 'with columns whose every value is an integer-like string' do
        let(:row_enum) do
          [['123', '4567'],
           ['6789', '-0']]
        end
        it 'will align right' do
          rendered_table.should eql(<<-HERE.gsub(/^(?:  ){6}/, ''))
             123 4567
            6789   -0
          HERE
        end
      end
      context 'when you have floating-point like doo-hahs, something magic happens' do
        let(:row_enum) do
          [['1', '2'],
           ['34','56'],
           ['1.348', '-3.14'],
           ['1234.5678', '0']]
        end
        it 'makes the decimal points line up', {wip:true} do
          puts "OK:\n#{rendered_table}"
        end
      end
    end
  end
end

