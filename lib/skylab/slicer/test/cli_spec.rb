require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "[sli]" do

    extend TS_

    as :exp, /\AExpecting .*transfer/, :styled
    as :inv, /\Atry wtvr -h \[sub-cmd\] for help\.\z/i, :styled

    context "canon" do

      it "0" do
        # debug!
        invoke []
        expect [ :exp, :inv ]
      end
    end
  end
end
