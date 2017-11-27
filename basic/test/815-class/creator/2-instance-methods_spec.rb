require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] class - creator - instance methods" do

    TS_[ self ]
    use :class_creator, Cls_Crtr_IM___ = ::Module.new

    context "minimal" do
      snip
      it "zeep" do
        k = o.klass! :Feep
        expect( k ).to be_kind_of(::Class)
        expect( k.to_s ).to eql('Feep')
        expect( k.instance_methods(false) ).to eql([])
        expect( k.object_id ).to eql((o.klass! :Feep).object_id)
        expect( k.ancestors[1] ).to eql(::Object)
      end
    end

    context "to to manipulate as a class s/thing started as a module.." do
      snip
      doing do
        o.modul! :Wonder
        o.klass! :Wonder
      end
      borks "Wonder is not a class (it's a Module)"
    end

    context "but NOTE s/thing that started as a class is ok as a module" do
      snip
      doing do
        o.klass! :Wonder
        o.modul! :Wonder
      end
      it "is ok to do *for now*" do
        x = subject.call
        expect( x.to_s ).to eql('Wonder')
        expect( x.class ).to eql(::Class)
      end
    end

    context "convoluted example - for now it manages to vivify all of these" do

      snip do
        klass :Fakon__Bakon
        klass :Fakon__Jakon
        klass :Fakon__Bakon__Wilbur
        klass :Mason__Dixon
      end

      it ".. (but note that you will get into some problems#{
        } with cyc. deps soon!)" do
        o.klass! :Jasper, extends: :Fakon__Bakon__Wilbur
        m = o.meta_hell_anchor_module

        these = m.constants
        these.sort!
        these == %i( Fakon Jasper Mason ) || fail

        expect( m::Fakon.constants ).to eql([:Bakon, :Jakon])
      end
    end
  end
end
