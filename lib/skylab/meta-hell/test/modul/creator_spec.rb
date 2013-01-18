require_relative 'creator/test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator
  describe "say, did you know that when using #{MetaHell::Modul::Creator}" do
    extend Creator_TestSupport


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

    context "multi-statement kicking of children" do
      snip do
        modul :American__Family
        modul :American__Gothic
      end
      it "happens" do
        o.American.constants.length.should eql(2)
      end
    end

    context "and holy crap what is this shit" do
      snip do
        modul( :My__Pho )     { def zap ; end }
        modul( :My__BaMi )    { def zip ; end ; def zoop ; end }
        modul( :His__Pho )    { def glyph ; end }
        modul :My__BaMi do
          undef_method :zip
          def zip a
          end
          def zorp
          end
        end
        modul( :My__Pho__Pas ) { def zangeif ; end }
      end

      it "per module appears to follow the order it was defined in" do
        o.My__BaMi.instance_methods.should eql([:zip, :zoop, :zorp])
        o.My__BaMi.instance_method(:zip).parameters.should eql([[:req, :a]])
      end

      it "looks like it realizes the whole graph, but still lazily wtf!!" do
        m = o.meta_hell_anchor_module
        m.constants.should eql([])
        o.My__Pho
        m.object_id.should eql(o.meta_hell_anchor_module.object_id)
        m.constants.should eql([:My, :His])
        x = m.const_get(:My, false).const_get(:Pho, false).const_get(:Pas, false)
        x.instance_methods.should eql([:zangeif])
      end
    end
  end
end
