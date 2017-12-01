require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - intro" do

    TS_[ self ]
    use :my_API

    context '(ping)' do

      call_by do
        call :ping
      end

      it 'works (result is nil)' do
        result_is_nothing
      end

      it "emits" do

        _be_this = be_emission_ending_with :expression, :ping do |y|
          y == [ "pong from doc-test** ! **" ] || fail
        end

        expect( only_emission ).to _be_this
      end
    end

    context '(strange)' do

      call_by do
        call :strange
      end

      it 'fails' do
        fails
      end

      it "emits" do

        _be_this = be_emission_ending_with :no_such_association do |ev|

          _ = black_and_white ev
          _.include? "no such association 'strange'" or fail
        end

        expect( only_emission ).to _be_this
      end
    end
  end
end
