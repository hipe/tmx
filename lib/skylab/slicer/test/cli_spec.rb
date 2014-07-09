require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "[sl]" do

    extend Slicer_TestSupport

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
