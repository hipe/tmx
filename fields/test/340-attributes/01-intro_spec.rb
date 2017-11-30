require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    context "five fields of [ `foo` | `flag` ][..]" do

      given_the_attributes_ do

        attributes_(
          one: nil,
          two: [ :_foo, :flag ],
          three: :flag,
          four: :_foo,
          five: [ :_zazzle, :optional ],
        )
      end

      it "you can request those of a custom symbol" do

        o = the_attributes_
        expect( o.symbols( :_foo ) ).to eql %i( two four )
        expect( o.symbols( :_zazzle ) ).to eql %i( five )
      end

      it "you can request those fields of no symbol" do

        _ = the_attributes_.symbols
        expect( _ ).to eql [ :one, :two, :three, :four, :five ]  # eek depends on hash order
      end

      it "you can request an individual formal attribute" do
        :one == the_attributes_.attribute( :one ).argument_arity or fail
      end

      it "(argument arity of flag)" do
        :zero == the_attributes_.attribute( :two ).argument_arity or fail
      end

      context "set ivar" do

        shared_subject :_state do

          _x_a = [ :one, :ONE, :two, :three, :four, :FOUR ]

          o = ::Object.new
          the_attributes_.init o, _x_a
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
          expect( a.fetch( 0 ) ).to eql :ONE
          expect( a.fetch( 3 ) ).to eql :FOUR
        end

        it "flags get set" do
          expect( _state[ 1, 2 ] ).to eql [ true, true ]
        end

        it "ivars are nillified IFF `optional` meta-flag" do
          expect( _state.fetch( 4 ) ).to be_nil
        end
      end
    end
  end
end
