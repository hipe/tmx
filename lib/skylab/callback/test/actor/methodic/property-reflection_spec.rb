require_relative 'test-support'

module Skylab::Callback::TestSupport::Actor::Methodic::PR

  Parent_TS_ = Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Grandparent_Subject_ = Parent_TS_::Parent_subject_

  describe "[cb] actor - methodic - property reflection" do

    context "two unadorned monadic properties" do

      before :all do

        class A
          Grandparent_Subject_[].methodic self, :simple, :properties,
            :properties, :one, :two
        end
      end

      it "loads" do
      end

      it "`<actor>.properties.fetch` with a symbol name, against a good name" do
        prop = A.properties.fetch :two
        prop.name_i.should eql :two
      end

      it "with an else block has no effect, same result as above" do
        prop = A.properties.fetch :one do :_no_see_ end
        prop.name_i.should eql :one
      end

      it "fetch nonexistent term without an else block - key error" do
        _rx = %r(\Akey not found: :three\b)
        -> do
          A.properties.fetch :three
        end.should raise_error ::KeyError, _rx
      end

      it "fetch a nonexistent term with an else block - your block is called" do
        prop = A.properties.fetch :four do :_see_ end
        prop.should eql :_see_
      end
    end
  end
end
