require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity::Properties_Stack__::Common_Frame__

  describe "[br] Entity::Properties_Stack__::Common_Frame__", wip: true do
    context "use its memoized and non-memoized procs and inline methods" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            Brazen_.properties_stack.common_frame self,
              :proc, :foo, -> do
                 d = 0
                 -> { d += 1 }
              end.call,
              :memoized, :proc, :bar, -> do
                d = 0
                -> { d += 1 }
              end.call,
              :inline_method, :bif, -> do
                "_#{ foo }_"
              end,
              :memoized, :inline_method, :baz, -> do
                "<#{ foo }>"
              end
          end

          # one chunk #until:[#ts-032]

          foo = Foo.new
          foo.foo.should eql( 1 )
          foo.foo.should eql( 2 )
          foo.bar.should eql( 1 )
          foo.bar.should eql( 1 )
          foo.bif.should eql( "_3_" )
          foo.bif.should eql( "_4_" )
          foo.baz.should eql( "<5>" )
          foo.baz.should eql( "<5>" )
          foo.baz.object_id.should eql( foo.baz.object_id )
        end
      end
    end
    context "[ `required` ] `field`s -" do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            Brazen_.properties_stack.common_frame self,
              :globbing, :processor, :initialize,
              :required, :readable, :field, :foo,
              :readable, :field, :bar
          end
        end
      end
      it "failing to provide a required field triggers an argument error" do
        Sandbox_2.with self
        module Sandbox_2
          _rx = ::Regexp.new( "\\Amissing\\ required\\ field\\ \\-\\ 'foo'\\z" )
          -> do
            Foo.new
          end.should raise_error( ArgumentError, _rx )
        end
      end
      it "passing nil is considered the same as not passing an argument" do
        Sandbox_2.with self
        module Sandbox_2
          _rx = ::Regexp.new( "\\Amissing\\ required\\ field\\ \\-\\ 'foo'\\z" )
          -> do
            Foo.new( :foo, nil )
          end.should raise_error( ArgumentError, _rx )
        end
      end
      it "passing false is not the same as passing nil, passing false is valid." do
        Sandbox_2.with self
        module Sandbox_2
          Foo.new( :foo, false ).foo.should eql( false )
        end
      end
      it "you can of course pass nil as the value for a non-required field" do
        Sandbox_2.with self
        module Sandbox_2
          Foo.new( :foo, :x, :bar, nil ).bar.should eql( nil )
        end
      end
    end
  end
end
