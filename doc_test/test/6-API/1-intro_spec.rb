require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - intro" do

    TS_[ self ]
    use :my_API

    context '(ping)' do

      call_by do
        call :ping
      end

      it 'works' do
        root_ACS_result == :_hello_from_doc_test_ || fail
      end

      it "emits" do
        _be_this = be_emission_ending_with :expression, :ping do |y|
          y == [ "ping ** ! **" ] || fail
        end
        only_emission.should _be_this
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

        only_emission.should _be_this
      end
    end
  end
end
