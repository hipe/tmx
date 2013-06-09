require_relative 'test-support'

module Skylab::Headless::TestSupport::Arity

  ::Skylab::Headless::TestSupport[ Arity_TestSupport = self ]

  include CONSTANTS

  Headless = ::Skylab::Headless  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Headless::Arity" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "usage:" do
        Sandbox_1.with self
        module Sandbox_1
          Headless::Arity::NAMES_.should eql( [ :zero, :zero_or_one, :zero_or_more, :one, :one_or_more ] )
          Headless::Arity::EACH_.first.local_normal_name.should eql( :zero )
          Headless::Arity[ :one_or_more ].is_unbounded.should eql( true )
        end
      end
    end
  end
end
