require_relative 'test-support'

module Skylab::Cull::TestSupport

  describe "[cu]" do

    extend TS_

    as :exp, /\AExpecting init/, :styled
    as :inv, /\ATry wtvr -h \[sub-cmd\] for help\.\z/i, :styled

    context "canon" do

      it "0" do
        # debug!
        invoke []
        expect [ :exp, :inv ]
      end
    end
  end
end
