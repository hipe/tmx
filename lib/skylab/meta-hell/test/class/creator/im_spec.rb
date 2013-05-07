require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Class::Creator
  describe "#{MetaHell::Class::Creator::InstanceMethods}" do
    extend Creator_TestSupport

    context "minimal" do
      snip
      it "zeep" do
        k = o.klass! :Feep
        k.should be_kind_of(::Class)
        k.to_s.should eql('Feep')
        k.instance_methods(false).should eql([])
        k.object_id.should eql((o.klass! :Feep).object_id)
        k.ancestors[1].should eql(::Object)
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
        x.to_s.should eql('Wonder')
        x.class.should eql(::Class)
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
        m.constants.should eql([:Fakon, :Mason, :Jasper])
        m::Fakon.constants.should eql([:Bakon, :Jakon])
      end
    end
  end
end
