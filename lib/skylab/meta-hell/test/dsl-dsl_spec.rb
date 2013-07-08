require_relative 'test-support'

module Skylab::MetaHell::TestSupport::DSL_DSL

  ::Skylab::MetaHell::TestSupport[ DSL_DSL_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::DSL_DSL" do
    context "this DSL_DSL is a simple DSL for making simple DSL's." do
      Sandbox_1 = Sandboxer.spawn
      it "introductory example" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            MetaHell::DSL_DSL.enhance self do
              atom :wiz                     # make an atomic (basic) field
            end                             # called `wiz`

            wiz :fiz                        # set a default here if you like
          end

          class Bar < Foo                   # subclass..
            wiz :piz                        # then set the value of `wiz`
          end
                                            # read the value:
          Bar.wiz_value.should eql( :piz )

          # but setters are private by default:

          -> do
            Bar.wiz :other
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aprivate\\ method\\ `wiz'\\ called" ) )

          # because this DSL generates only readers and not writers for your
          # instances, you get a public reader of the same name in your
          # instances (not suffixed with "_value").

                                             # read the value in an instance:
          Bar.new.wiz.should eql( :piz )
        end
      end
    end
    context "`block` define the value with a block" do
      Sandbox_2 = Sandboxer.spawn
      it "but note you use `foo.call` from the instance" do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            MetaHell::DSL_DSL.enhance self do
              block :zinger
            end
          end

          class Bar < Foo
            ohai = 0
            zinger do
              ohai += 1
            end
          end

          bar = Bar.new
          bar.zinger.call.should eql( 1 )
          bar.zinger.call.should eql( 2 )
        end
      end
    end
    context "`atom_accessor` lets you access the field" do
      Sandbox_3 = Sandboxer.spawn
      it "in the instance in the same DSL-y way as in the class" do
        Sandbox_3.with self
        module Sandbox_3
          class Foo
            MetaHell::DSL_DSL.enhance self do
              atom_accessor :with_name
            end
          end

          foo = Foo.new
          foo.with_name :x
          foo.with_name.should eql( :x )
        end
      end
    end
    context "can we use a module to hold and share an entire DSL?" do
      Sandbox_4 = Sandboxer.spawn
      it "you can attempt to make a DSL reusable and inheritable like so" do
        Sandbox_4.with self
        module Sandbox_4
          module Foo
            MetaHell::DSL_DSL.enhance_module self do
              atom :pik
            end
          end

          class Bar
            extend Foo::ModuleMethods
            include Foo::InstanceMethods
            pik :nic
          end

          Bar.pik_value.should eql( :nic )
          Bar.new.pik.should eql( :nic )
        end
      end
    end
  end
end
