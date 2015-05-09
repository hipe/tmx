require_relative '../test-support'

module Skylab::Parse::TestSupport

  module DD___  # :+#throwaway-module for constants created during tests

    # <-

  TS_.describe "[pa] DSL_DSL" do

    context "if you define an `atom` field called 'wiz'" do

      before :all do
        class Foo
          Parse_::DSL_DSL.enhance self do
            atom :wiz                     # make an atomic (basic) field
          end                             # called `wiz`

          wiz :fiz                        # set a default here if you like
        end

        class Bar < Foo                   # subclass..
          wiz :piz                        # then set the value of `wiz`
        end
      end

      it "you can read this value on the pertinent classes with `wiz_value`" do
        Bar.wiz_value.should eql :piz
      end

      it "these setter module methods are by default private" do
        -> do
          Bar.wiz :other
        end.should raise_error( NoMethodError,
                     ::Regexp.new( "\\Aprivate\\ method\\ `wiz'\\ called" ) )
      end

      it "you get a public instance getter of the same name (no `_value` suffix)" do
        Bar.new.wiz.should eql :piz
      end
    end

    context "a `block` field called 'zinger' gives you an eponymous proc writer" do

      before :all do
        class Fob
          Parse_::DSL_DSL.enhance self do
            block :zinger
          end
        end

        class Bab < Fob
          ohai = 0
          zinger do
            ohai += 1
          end
        end
      end

      it "you must use `zinger.call` on the instance" do
        bar = Bab.new
        bar.zinger.call.should eql 1
        bar.zinger.call.should eql 2
      end
    end

    context "if you define an `atom_accessor` field 'with_name'" do

      before :all do
        class Foc
          Parse_::DSL_DSL.enhance self do
            atom_accessor :with_name
          end
        end
      end

      it "in the instance you can write to the field in the same DSL-y way" do
        foo = Foc.new
        foo.with_name :x
        foo.with_name.should eql :x
      end
    end

    context "if you must, use a module and not a class to encapsulate reusability" do

      before :all do
        module Fod
          Parse_::DSL_DSL.enhance_module self do
            atom :pik
          end
        end

        class Badd
          extend Fod::ModuleMethods
          include Fod::InstanceMethods
          pik :nic
        end
      end

      it "you can enhance a class with your module with the above two steps" do
        Badd.pik_value.should eql :nic
        Badd.new.pik.should eql :nic
      end
    end
  end
# ->
  end
end
