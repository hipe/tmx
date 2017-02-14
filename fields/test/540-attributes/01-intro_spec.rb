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
        o.symbols( :_foo ).should eql %i( two four )
        o.symbols( :_zazzle ).should eql %i( five )
      end

      it "you can request those fields of no symbol" do

        _ = the_attributes_.symbols
        _.should eql [ :one, :two, :three, :four, :five ]  # eek depends on hash order
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
  end
end
