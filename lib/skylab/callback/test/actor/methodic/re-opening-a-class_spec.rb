require_relative 'test-support'

module Skylab::Callback::TestSupport::Actor::Methodic::ROAC

  Parent_TS_ = Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Grandparent_Subject_ = Parent_TS_::Parent_subject_

  describe "[ca] actor - methodic - re-opening a class" do

    context "you do it with 'o'" do

      before :all do

        class A
          Grandparent_Subject_[].methodic self, :simple, :properties, :properties, :a, :b

          o :simple, :properties, :properties, :x, :y
        end
      end

      it "loads" do
      end

      it "reflects" do
        A.properties.get_names.should eql [ :a, :b, :x, :y ]
      end
    end
  end
end
