require File.expand_path('../../table', __FILE__)
require 'stringio'

module Skylab::Porcelain::TestSupport
  include Skylab
  describe Porcelain::Table do
    let(:subject) { Porcelain }
    let(:_stdout) { StringIO.new }
    let(:stdout) { _stdout.string }
    context Porcelain::Table do
      specify { should be_const_defined(:Table) }
      specify { should be_respond_to(:Table) }
    end
    context "rendering tables" do
      it "renders the empty table" do
        Porcelain.Table([]) { |o| o.on_all { |e| _stdout.puts e } }
        stdout.should eql("(empty)\n")
      end
    end
  end
end

