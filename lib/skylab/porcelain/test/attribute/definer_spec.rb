require_relative '../test-support'

require 'set'

describe Skylab::Porcelain::Attribute::Definer do
  module Helper
    def one_such_class &block
      Class.new.class_eval do
        extend ::Skylab::Porcelain::Attribute::Definer
        instance_eval( &block )
        self
      end
    end
  end
  Porcelain = Skylab::Porcelain
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
    klass.attributes.names.to_set.should eql([:bar, :foo].to_set)
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
      klass_b.attributes.names.to_set.should eql([:foo, :bar].to_set)
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
      klass_b.attributes.fetch(:foo)[:fooish].should eql(false)
      klass_a.attributes.fetch(:foo)[:fooish].should eql(true)
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
        klass_b.meta_attributes.names.to_set.should eql([:height, :weight].to_set)
      end
      it "but adding things to the parent dynamically won't inherit" do
        klass_a.meta_attribute :age
        klass_b.meta_attributes.names.to_set.should eql([:height, :weight, :age].to_set)
        klass_a.meta_attribute :volume
        klass_b.meta_attributes.names.to_set.should eql([:height, :weight, :age].to_set)
      end
    end
    describe "you can define hooks" do
      it "that are called when you define attributes with those meta attributes" do
        klass_a = one_such_class do
          meta_attribute :whoopie
          def self.on_whoopie_attribute name, meta
            remove_method name
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
  describe "lets you import meta attribute definitions from modules" do
    let(:defining_module) do
      Module.new.module_eval do
        class << self ; def to_s ; 'defining_module' end end
        extend Porcelain::Attribute::Definer
        meta_attribute :regex do |name, meta|
          alias_method(after = "#{name}_after_regex=", "#{name}=")
          define_method("#{name}=") do |str|
            if meta[:regex] =~ str
              send(after, str)
            else
              emit(:error, "#{str.inspect} did not match regex: /#{meta[:regex].source}/")
              str
            end
          end
        end
        self
      end
    end
    let(:importing_class) do
      ctx = self
      Class.new.class_eval do
        class << self ; def to_s ; 'importing_class' end end
        extend Porcelain::Attribute::Definer
        meta_attribute ctx.defining_module
        self
      end
    end
    let(:stdout) { [] }
    let(:child_class) do
      ctx = self
      Class.new(importing_class).class_eval do
        attribute :first_name, :regex => /^[A-Z]/
        define_method(:emit) { |_, s| ctx.stdout.push s }
        self
      end
    end
    it "which transfers the same MetaAttribute object to child (should be ok)" do
      importing_class.meta_attributes[:regex].should be_kind_of(Porcelain::Attribute::MetaAttribute)
      importing_class.meta_attributes[:regex].object_id.should eql(defining_module.meta_attributes[:regex].object_id)
    end
    it "also it transfers the attribute definition hook from the module" do
      defining_module.should respond_to(:on_regex_attribute)
      importing_class.should respond_to(:on_regex_attribute)
    end
    it "and which will work e.g. from an object of a child class", {f:true} do
      o = child_class.new
      o.first_name.should be_nil
      o.first_name = "Billford Brimley"
      o.first_name.should eql("Billford Brimley")
      stdout.size.should be_zero
      o.first_name = "toff tofferson"
      stdout.size.should eql(1)
      stdout.last.should eql('"toff tofferson" did not match regex: /^[A-Z]/')
      o.first_name.should eql("Billford Brimley")
    end
  end
end
