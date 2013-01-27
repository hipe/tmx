require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "#{ Skylab::Treemap::Adapter } whackily hand-written sub_ext" do

    rx = Treemap::Adapter::FUN.extname_rx

    let( :match_data ) { rx.match input }

    null_a = [ nil, nil ]

    let :subject do
      ( md = match_data ) ? [ md[:stem], md[:extname] ] : null_a
    end

    def self.o input, output, *rest
      context "#{ input.inspect }" do
        let :input do
          input
        end
        specify do
          should eql( output )
        end
      end
    end

    context "matches the set of all strings" do
      o '', ['', nil]
      o '.', ['', '.']
      o '..', ['.','.']
      o '...', ['..','.']
      o '.abc', ['', '.abc']
      o 'abc.', ['abc', '.']
      o 'foo', ['foo', nil]
      o 'foo.bar', ['foo', '.bar']
      o 'foo.bar.baz', ['foo.bar', '.baz']
    end
  end
end
