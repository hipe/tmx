require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] module - creator - instance-methods" do

    TS_[ self ]
    use :module_creator_define_klass, Mdl_Crtr_IM__ = ::Module.new

    context "minimal" do

      define_klass_

      it "puts the module under the anchor module, writes name, accessor" do

        o = klass_.new
        m = o.meta_hell_anchor_module
        o.meta_hell_anchor_module.object_id.should eql(m.object_id)
        m.constants.length.should eql(0)
        m1 = o.modul! :Nerpulous
        m.constants.length.should eql(1)
        m2 = o.modul! :Nerpulous
        m3 = o.Nerpulous
        m4 = o._Nerpulous
        a = [m1, m2, m3, m4]
        a.select{ |x| x }.length.should eql(a.length)
        a.map(&:object_id).uniq.length.should eql(1)
        a.first.should be_kind_of(::Module)
        a.first.to_s.should eql('Nerpulous')
      end
    end

    context "block" do

      define_klass_

      it "one def" do

        o = klass_.new
        o.modul! :Neeble do
          def xx ; end
        end
        o._Neeble.instance_methods.should eql([:xx])
      end

      it "two defs" do

        o = klass_.new
        o.modul!( :Zip ) { def zang ; end }
        o.modul!( :Zip ) { def pang ; end }
        o.modul!(:Zip).instance_methods.should eql([:zang, :pang])
      end
    end

    context "second level, minimal" do

      define_klass_

      it "makes both levels, non-lazy" do

        o = klass_.new
        m = o.meta_hell_anchor_module
        o.modul! :Nerp__Ferp
        m.constants.should eql([:Nerp])
        m::Nerp::Ferp.should be_kind_of(::Module)
      end
    end

    context "classes vs. objects -- objects don't change defs in classes" do

      define_klass_ do

        modul :Home__Boy
      end

      it "wow amazing" do

        o1 = klass_.new
        o2 = klass_.new
        m1 = o1.meta_hell_anchor_module
        m2 = o2.meta_hell_anchor_module
        m1.constants.should be_empty
        ( m1.object_id == m2.object_id ).should eql( false )
        o1.modul! :Home__Girl
        m1.constants.length.should eql(1)
        m2.constants.length.should eql(0)
        m1::Home.constants.should eql([:Boy, :Girl])
      end
    end
  end
end
