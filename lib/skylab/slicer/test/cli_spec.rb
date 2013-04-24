require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "#{ Slicer }" do

    extend Slicer_TestSupport

    as :exp, /\AExpecting .*transfer/, :styled
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
