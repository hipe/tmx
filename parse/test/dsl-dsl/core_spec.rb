require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] DSL_DSL" do

    context "this DSL_DSL is a simple DSL for making simple DSL's." do

      before :all do

        module X_dd_c_Foo
          class Base

            Home_::DSL_DSL.enhance self do
              atom :wiz                     # make an atomic (basic) field
            end                             # called `wiz`

            wiz :fiz                        # set a default here if you like
          end

          class Bar < Base                  # subclass..
            wiz :piz                        # then set the value of `wiz`
          end
        end
      end

      it "you can read this value on the pertinent classes with `wiz_value`" do
        X_dd_c_Foo::Bar.wiz_value.should eql :piz
      end

      it "these setter module methods are by default private" do
        _rx = ::Regexp.new "\\Aprivate\\ method\\ `wiz'\\ called"

        begin
          X_dd_c_Foo::Bar.wiz :other
        rescue NoMethodError => e
        end

        e.message.should match _rx
      end

      it "you get a public instance getter of the same name (no `_value` suffix)" do
        X_dd_c_Foo::Bar.new.wiz.should eql :piz
      end
    end

    context "a `block` field called 'zinger' gives you an eponymous proc writer" do

      before :all do
        module X_dd_c_Fob
          class Base
            Home_::DSL_DSL.enhance self do
              block :zinger
            end
          end

          class Bar < Base
            ohai = 0
            zinger do
              ohai += 1
            end
          end
        end
      end

      it "you must use `zinger.call` on the instance" do
        bar = X_dd_c_Fob::Bar.new
        bar.zinger.call.should eql 1
        bar.zinger.call.should eql 2
      end
    end

    context "if you define an `atom_accessor` field 'with_name'" do

      before :all do
        class X_dd_c_Foc
          Home_::DSL_DSL.enhance self do
            atom_accessor :with_name
          end
        end
      end

      it "in the instance you can write to the field in the same DSL-y way" do
        foo = X_dd_c_Foc.new
        foo.with_name :x
        foo.with_name.should eql :x
      end
    end

    context "if you must, use a module and not a class to encapsulate reusability" do

      before :all do
        module X_dd_c_Fod
          module ExtensionModule
            Home_::DSL_DSL.enhance_module self do
              atom :pik
            end
          end

          class Bar
            extend ExtensionModule::ModuleMethods
            include ExtensionModule::InstanceMethods
            pik :nic
          end
        end
      end

      it "then you can enhance a class with your module with the above two steps" do
        X_dd_c_Fod::Bar.pik_value.should eql :nic
        X_dd_c_Fod::Bar.new.pik.should eql :nic
      end
    end
  end
end
