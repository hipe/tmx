require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] parameters" do

    TS_[ self ]
    use :memoizer_methods

    context "five fields of [ `foo` | `flag` ][..]" do

      shared_subject :_params do

        _subject[
          one: nil,
          two: [ :foo, :flag ],
          three: :flag,
          four: :foo,
          five: [ :zazzle, :optional ],
        ]
      end

      it "you can request those of a custom symbol" do

        o = _params
        o.symbols( :foo ).should eql %i( two four )
        o.symbols( :zazzle ).should eql %i( five )
      end

      it "you can request those fields of no symbol" do

        _ = _params.symbols
        _.should eql [ :one, :two, :three, :four, :five ]  # eek depends on hash order
      end

      context "set ivar" do

        shared_subject :_state do

          _x_a = [ :one, :ONE, :two, :three, :four, :FOUR ]

          o = ::Object.new
          _params.init o, _x_a
          a = []
          o.instance_exec do
            a.push @one, @two, @three, @four
          end

          if o.instance_variable_defined? :@five
            a.push o.instance_variable_get :@five
          end

          a.freeze
        end

        it "fields get set" do
          a = _state
          a.fetch( 0 ).should eql :ONE
          a.fetch( 3 ).should eql :FOUR
        end

        it "flags get set" do
          _state[ 1, 2 ].should eql [ true, true ]
        end

        it "ivars are nillified IFF `optional` meta-flag" do
          _state.fetch( 4 ).should be_nil
        end
      end
    end

    def _subject
      Home_::Parameters
    end
  end
end
# #pending-rename: branch down