require_relative 'test-support'

module Skylab::Cull::TestSupport

  describe "#{ Cull }" do

    extend Cull_TestSupport

    as :exp, /\AExpecting init/, :styled
    as :inv, /\ATry wtvr -h \[sub-cmd\] for help\.\z/, :styled

    context "canon" do

      it "0" do
        # debug!
        invoke []
        expect [ :exp, :inv ]
      end
    end
  end
end
