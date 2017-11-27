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
        expect( o.meta_hell_anchor_module.object_id ).to eql(m.object_id)
        expect( m.constants.length ).to eql(0)
        m1 = o.modul! :Nerpulous
        expect( m.constants.length ).to eql(1)
        m2 = o.modul! :Nerpulous
        m3 = o.Nerpulous
        m4 = o._Nerpulous
        a = [m1, m2, m3, m4]
        expect( a.select{ |x| x }.length ).to eql(a.length)
        expect( a.map(&:object_id).uniq.length ).to eql(1)
        expect( a.first ).to be_kind_of(::Module)
        expect( a.first.to_s ).to eql('Nerpulous')
      end
    end

    context "block" do

      define_klass_

      it "one def" do

        o = klass_.new
        o.modul! :Neeble do
          def xx ; end
        end
        expect( o._Neeble.instance_methods ).to eql([:xx])
      end

      it "two defs" do

        o = klass_.new
        o.modul!( :Zip ) { def zang ; end }
        o.modul!( :Zip ) { def pang ; end }
        expect( o.modul!(:Zip).instance_methods ).to eql([:zang, :pang])
      end
    end

    context "second level, minimal" do

      define_klass_

      it "makes both levels, non-lazy" do

        o = klass_.new
        m = o.meta_hell_anchor_module
        o.modul! :Nerp__Ferp
        expect( m.constants ).to eql([:Nerp])
        expect( m::Nerp::Ferp ).to be_kind_of(::Module)
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
        expect( m1.constants ).to be_empty
        expect( ( m1.object_id == m2.object_id ) ).to eql( false )
        o1.modul! :Home__Girl
        expect( m1.constants.length ).to eql(1)
        expect( m2.constants.length ).to eql(0)
        expect( m1::Home.constants ).to eql([:Boy, :Girl])
      end
    end
  end
end
