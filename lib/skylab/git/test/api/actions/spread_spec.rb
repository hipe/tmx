require_relative '../../test-support'

module Skylab::Git::TestSupport::API
  Actions = ::Module.new
end

module Skylab::Git::TestSupport::API::Actions::Spread

  ::Skylab::Git::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Spread = Git_::CLI::Actions::Spread

  describe "[gi] API actions spread" do

    extend TS_

    def snitch
      @snitch ||= begin
        @do_debug ||= do_debug
        @err_a ||= [ ]
        Spread::Support__::Snitch.new( ::Enumerator::Yielder.new do |msg|
          @do_debug and TestSupport_::System.stderr.puts msg
          @err_a << msg
        end, :no_context )
      end
    end

    def self.branches a
      let :branches do
        Spread::API_Model::Branches.from_line_scanner(
          Git_._lib.scanner( a ), snitch )
      end
    end

    def cut line  # #hack-alert
      NUM_RX_ =~ (( s = line[ 19, 2 ] )) or fail "output line didn't #{
        }match up with expected output alignment - #{ line } (near #{
        }#{ s.inspect })"
      s.to_i
    end

    NUM_RX_ = /\A\d+\z/

    context "spread" do

      def move from_d, to_d
        Spread::Move_Request_[ from_d, to_d ]
      end

      context "basic spread" do

        branches %w( 02-A 07-B 09-C )

        it "spread" do
          branches.invoke :spread, :move_request_a, [ move( 7, 4 ) ],
            :outstream, outstream
          expect 'git branch -m 02-A 01-A'
          expect 'git branch -m 07-B 04-B'
          expect_final  'git branch -m 09-C 06-C'
        end

        it "source not found" do
          branches.invoke :spread, :move_request_a, [ move( 6, 6 ) ]
          expect_err "error - no such starting number: 6"
        end
      end

      context "other spread" do

        branches %w( 01-a 03-a 05-a 10-a 12-a )

        it "ok" do
          branches.invoke :spread, :move_request_a, [ move( 5, 8 ) ],
            :outstream, outstream
          @out_a.map( & method( :cut ) ).to_a.
            should eql( [ 1, 4, 8, 13, 15 ] )
        end

        it "duplicates (too crowded)" do
          branches.invoke :spread, :move_request_a, [ move( 12, 2 ) ]
          expect_err( /number collision.+3 times/ )
        end
      end
    end

    context "spread - evenulate" do

      branches %w( 01-a 03-b 04-c 05-d )

      it "go" do
        branches.invoke :evenulate, :outstream, outstream
        a = @out_a.map( & method( :cut ) )
        a.should eql( [ 2, 4, 6, 8 ] )
      end
    end
  end
end
