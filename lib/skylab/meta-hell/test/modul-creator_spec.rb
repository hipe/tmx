require_relative 'modul-creator/test-support'

module ::Skylab::MetaHell::TestSupport::ModulCreator
  describe "#{MetaHell::ModulCreator} uber alles" do
    extend ModulCreator_TestSupport


    context "defining a single module" do
      context "with no block" do
        snip do
          modul :American
        end
        it "works, is persistent, gives you a convenience accessor" do
          o.American.should be_kind_of(::Module)
          o.American.object_id.should eql(o.American.object_id)
          o._American.should eql(o.American)
        end
      end
      context "with a block" do
        snip do
          modul :American do
            def fizzo ; :bizzo end
          end
        end
        it "works" do
          o.American.instance_methods.should eql([:fizzo])
        end
      end
    end

    context "defining a nested module (1 level)" do
      context "with no block" do
        snip do
          modul :American__Family
        end
        it "things are persistent everywhere" do
          m1 = o.American
          m2 = o.American__Family
          m3 = m1::Family
          m4 = o.American.const_get :Family, false
          [m2, m3, m4].map(&:object_id).uniq.length.should eql(1)
          m1.object_id.should eql(o.American.object_id)
        end
        it "lazy eval. vs. kicks" do
          o.American.constants.length.should eql(1)
          o.American__Family
          o.American.constants.length.should eql(1)
        end
      end
    end
  end
end
