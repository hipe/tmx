require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Attribute::Box
  ::Skylab::MetaHell::TestSupport::Formal::Attribute[ self ]
  Box_TestSupport = self

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ MetaHell::Formal::Attribute::Box }" do

    extend Box_TestSupport

    context "`with` - doesn't care about truthiness just has?" do

      subject -> do
        MetaHell::Formal::Attribute::Box[ [
          [:one, { name: :foo, ready: true, flavor: :bland } ],
          [:two, { name: :bar, ready: false} ],
          [:three, { name: :baz, ready: true, flavor: :spicy } ],
          [:four, { name: :boffo, ready: false, flavor: nil } ]
        ] ]
      end

      it "like so" do
        ea = subject.with :flavor
        ea.should be_respond_to( :filter )
        a = ea.to_a
        a.length.should eql(3)
        a.map(&:normalized_name).should eql( [:one, :three, :four] )
        ea2 = ea.select { |x| x[:flavor] }
        a = ea2.to_a
        a.length.should eql( 2 )
      end
    end
  end
end
