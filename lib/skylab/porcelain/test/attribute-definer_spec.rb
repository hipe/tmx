require File.expand_path('../../attribute-definer', __FILE__)
require 'set'

describe Skylab::Porcelain::AttributeDefiner do
  module Helper
    def one_such_class &block
      Class.new.class_eval do
        extend ::Skylab::Porcelain::AttributeDefiner
        instance_eval &block
        self
      end
    end
  end
  include Helper
  extend Helper
  it "creates getter/setters on classes" do
    klass = one_such_class do
      attribute :foo
    end
    o = klass.new
    o.foo.should eql(nil)
    o.foo = 'bar'
    o.foo.should eql('bar')
  end
  it "allows reflection of what attribute names have been defined" do
    klass = one_such_class do
      attribute :foo
      attribute :bar
    end
    klass.attributes.keys.to_set.should eql([:bar, :foo].to_set)
  end
  describe "when dealing with class inheritance" do
    klass_a = one_such_class do
      attribute :foo
    end
    klass_b = Class.new(klass_a).class_eval do
      attribute :bar
      self
    end
    it "inherits the getters and setters" do
      b = klass_b.new
      b.foo = 'x'
      b.foo.should eql('x')
    end
    it "inherits the reflection" do
      klass_b.attributes.keys.to_set.should eql([:foo, :bar].to_set)
    end
  end
  describe "class inheritance with regards to metaproperties", {focus:true} do
    let(:klass_a) do
      one_such_class do
        meta_attribute :fooish
        attribute :foo, :fooish => true
      end
    end
    let(:klass_b) do
      Class.new(klass_a).class_eval do
        attribute :foo, :fooish => false
        self
      end
    end
    it "child classes must be able to override metaproperties" do
      klass_b.attributes[:foo][:fooish].should eql(false)
      klass_a.attributes[:foo][:fooish].should eql(true)
    end
  end
  describe "with meta attributes" do
    it "won't let you make them willy nilly" do
      lambda do
        one_such_class do
          attribute :derp, :herp => :lerp
        end
      end.should raise_exception(::RuntimeError, 'meta attributes must first be declared: :herp')
    end
    describe "they get inherited from parent" do
      let(:klass_a) { one_such_class { meta_attribute :height } }
      let(:klass_b) { Class.new(klass_a).class_eval { meta_attribute :weight; self } }
      it "as here" do
        klass_b.meta_attributes.keys.to_set.should eql([:height, :weight].to_set)
      end
      it "but adding things to the parent dynamically won't inherit" do
        klass_a.meta_attribute :age
        klass_b.meta_attributes.keys.to_set.should eql([:height, :weight, :age].to_set)
        klass_a.meta_attribute :volume
        klass_b.meta_attributes.keys.to_set.should eql([:height, :weight, :age].to_set)
      end
    end
    describe "you can define hooks" do
      it "that are called when you define attributes with those meta attributes" do
        klass_a = one_such_class do
          meta_attribute :whoopie
          def self.on_whoopie_attribute name, meta
            define_method(name) { "A:#{instance_variable_get("@#{name}")}:B" }
            touched.push [name, meta]
          end
        end
        klass_b = Class.new(klass_a).class_eval do
          @touched = []
          class << self ; attr_reader :touched end
          attribute :wankers, :whoopie => :nerp
          self
        end
        who, hah = klass_b.touched.first
        who.should eql :wankers
        hah.should eql(:whoopie => :nerp)
        obj = klass_b.new
        obj.wankers = 'derp'
        obj.wankers.should eql('A:derp:B')
      end
    end
  end
end

