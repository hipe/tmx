require File.expand_path('../../table', __FILE__)
require File.expand_path('../test-support', __FILE__)
require 'skylab/porcelain/bleeding'

module Skylab::Porcelain::TestSupport
  include Skylab
  describe Porcelain::Table do
    let(:subject) { Porcelain }
    let(:_stdout) { StringIO.new }
    let(:stdout) { _stdout.string }
    context Porcelain::Table do
      specify { should be_const_defined(:Table) }
    end
    context "#{Porcelain::Table::RenderTable} instance_methods" do
      let(:subject) { Porcelain::Table::RenderTable.instance_methods(false) }
      specify { should be_include(:render_table) }
    end
    context "rendering tables" do
      include Porcelain::Table::RenderTable
      it "renders the empty table" do
        r = render_table([]) { |o| o.on_all { |e| _stdout.puts e } }
        stdout.should eql("(empty)\n")
        r.should eql(nil)
      end
      it "you can also just get a string back" do
        render_table([]).should eql("(empty)\n")
      end
      it "renders a 2 x 2 table (align left)" do
        data = [ %w(derp mcderperson),
                 %w(herper mcderpertino) ]
        render_table(data).should eql(<<-HERE.unindent)
          derp   mcderperson 
          herper mcderpertino
        HERE
      end
      it "takes options the canonical way" do
        s = render_table([['a','b'],['c','dd']], :head => '<<', :tail => '>>', :separator => ' | ')
        s.should eql(<<-HERE.unindent)
          <<a | b >>
          <<c | dd>>
        HERE
      end
      it "takes options also in the block with the event knob" do
        render_table([['a','b'],['c','dd']]) do |o|
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
      include Porcelain::Table::RenderTable
      let(:rendered_table) { render_table(row_enum) }
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
          [['-1.1122', 'blah'],
           ['1', '2'],
           ['34.5','56'],
           ['1.348', '-3.14'],
           ['1234.567891', '0']]
        end
        it 'makes the decimal points line up!!!!!' do
          rendered_table.should eql(<<-HERE.gsub(/^(?:  ){6}/, ''))
              -1.1122    blah
               1            2
              34.5         56
               1.348    -3.14
            1234.567891     0
          HERE
        end
      end
      context "and when you have a mish-mash of different things" do
        let(:row_enum) do
          [['0123',  '0123',    '01233', '3.1415'],
           ['',      'meeper',  'eff',   '3.14'],
           ['012',   '01.2',    'ef',    '23.1415'],
           ['01',    '01',      'e',     '0']]
        end
        it "it uses the most frequently occuring type -- the mode" do
          rendered_table.should eql(<<-HERE.unindent)
            0123   0123 01233  3.1415
                 meeper eff    3.14  
             012   01.2 ef    23.1415
              01     01 e      0     
          HERE
        end
      end
    end
    context "automatic widths with (ascii escape code) styles" do
      include Porcelain::Table::RenderTable
      it 'works' do
        rows = [
          [[:header, 'name'], 'hipe'],
          [[:header, 'favorite fruits'], 'banana'],
          [nil, 'pear']
        ]
        output = []
        render_table(rows, :separator => "\t") do |o|
          o[:header].format { |s| Porcelain::Bleeding::Styles.hdr(s) }
          o.on_row { |e| output.push Headless::CLI::Stylize::FUN.unstylize[ e ]}
        end
        lengths = output.map { |s| s.match(/^[^\t]*/)[0].length }
        lengths.uniq.size.should eql(1)
      end
    end
  end
end

