require_relative 'test-support'

module Skylab::Basic::TestSupport::Rotating_Buffer

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Basic_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[ba] Rotating_Buffer" do
    context "it's just like tivo" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          rotbuf = Basic_::Rotating_Buffer.new 4
          rotbuf << :a << :b << :c << :d << :e
          rotbuf[ 2 ].should eql( :d )
          rotbuf[ -1 ].should eql( :e )
          rotbuf[ -4 ].should eql( :b )
          rotbuf[ -5 ].should eql( nil )
          rotbuf[ 0, 4 ].should eql( %i( b c d e ) )
          rotbuf[ -2 .. -1 ].should eql( %i( d e ) )
          rotbuf[ -10 .. -1 ].should eql( nil )
          rotbuf[ 2, 22 ].should eql( %i( d e ) )
        end
      end
    end
    context "and when you are" do
      Sandbox_2 = Sandboxer.spawn
      it "under buffer" do
        Sandbox_2.with self
        module Sandbox_2
          rotbuf = Basic_::Rotating_Buffer.new 5
          rotbuf << :a << :b << :c
          rotbuf[ -3 .. -1 ].should eql( %i( a b c ) )
        end
      end
    end
    context "'to_a' works on" do
      Sandbox_3 = Sandboxer.spawn
      it "short buffers" do
        Sandbox_3.with self
        module Sandbox_3
          r = Basic_::Rotating_Buffer.new 3
          r << :a << :b
          r.to_a.should eql( %i( a b ) )
        end
      end
    end
    context "'to_a' works on" do
      Sandbox_4 = Sandboxer.spawn
      it "cycled buffers" do
        Sandbox_4.with self
        module Sandbox_4
          r = Basic_::Rotating_Buffer.new 3
          r << :a << :b << :c << :d
          r.to_a.should eql( %i( b c d ) )
        end
      end
    end
  end
end
