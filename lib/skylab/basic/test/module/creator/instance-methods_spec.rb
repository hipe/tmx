require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Module::Creator

  describe "[mh] Module::Creator::InstanceMethods" do

    extend TS_

    context "minimal" do
      snip
      it "puts the module under the anchor module, writes name, accessor" do
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
      snip
      it "one def" do
        o.modul! :Neeble do
          def xx ; end
        end
        o._Neeble.instance_methods.should eql([:xx])
      end
      it "two defs" do
        o.modul!( :Zip ) { def zang ; end }
        o.modul!( :Zip ) { def pang ; end }
        o.modul!(:Zip).instance_methods.should eql([:zang, :pang])
      end
    end

    context "second level, minimal" do
      snip
      it "makes both levels, non-lazy" do
        m = o.meta_hell_anchor_module
        o.modul! :Nerp__Ferp
        m.constants.should eql([:Nerp])
        m::Nerp::Ferp.should be_kind_of(::Module)
      end
    end

    context "classes vs. objects -- objects don't change defs in classes" do
      snip do
        modul :Home__Boy
      end
      it "wow amazing" do
        o1 = klass.new
        o2 = klass.new
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
