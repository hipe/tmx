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
      it "renders a 2 x 2 table" do
        data = [ %w(eenie meenie),
                 %w(minie moe) ]
        Porcelain.table(data).should eql(<<-HERE.unindent)
          eenie meenie
          minie    moe
        HERE
      end
      it "takes options the canonical way" do
        s = Porcelain.table([['a','b'],['c','dd']], :head => '<<', :tail => '>>', :separator => ' | ')
        s.should eql(<<-HERE.unindent)
          <<a |  b>>
          <<c | dd>>
        HERE
      end
      it "takes options also in the block with the event knob" do
        Porcelain.table([['a','b'],['c','dd']]) do |o|
          o.head = '<<' ; o.tail = '>>' ; o.separator = ' | '
          o.on_all { |e| _stdout.puts e }
        end
        stdout.should eql(<<-HERE.unindent)
          <<a |  b>>
          <<c | dd>>
        HERE
      end
    end
  end
end

