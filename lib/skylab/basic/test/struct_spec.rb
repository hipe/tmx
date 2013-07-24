require_relative 'test-support'

module Skylab::Basic::TestSupport::Struct

  ::Skylab::Basic::TestSupport[ Struct_TestSupport = self ]

  include CONSTANTS

  Basic = ::Skylab::Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::Struct" do
    context "use it" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          Foo = Basic::Struct[ :nerp ]
        end
      end
      it "like this" do
        Sandbox_1.with self
        module Sandbox_1
          Foo.new.nerp.should eql( nil )
        end
      end
      it "beep" do
        Sandbox_1.with self
        module Sandbox_1
          Foo.new( :bleep ).nerp.should eql( :bleep )
        end
      end
      it "bingo" do
        Sandbox_1.with self
        module Sandbox_1
          foo = Foo.new
          foo.nerp = :dango
          foo.nerp.should eql( :dango )
        end
      end
      it "django unchained" do
        Sandbox_1.with self
        module Sandbox_1
          Foo.members.should eql( [ :nerp ] )
        end
      end
      it "hotsauce" do
        Sandbox_1.with self
        module Sandbox_1
          Foo.new.members.should eql( [ :nerp ] )
        end
      end
    end
  end
end
