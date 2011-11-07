require File.expand_path('../../attribute-definer', __FILE__)
require 'set'

module Skylab::Slake
  describe AttributeDefiner do
    it "should include into a class and let it use it" do
      some_class = Class.new.class_eval do
        extend AttributeDefiner
        attribute :ohai
        attribute :ohey, :required => false
        self
      end
      these = some_class.attributes
      these.keys.to_set.should eq([:ohai, :ohey].to_set)
      required_attrs = these.select{ |k, a| a[:required] }
      required_attrs.keys.to_set.should eq([:ohai].to_set)
    end
    it "should work" do
      some_class = Class.new.class_eval do
        extend AttributeDefiner
        attribute :ohai
        self
      end
      foo = some_class.new
      foo.ohai.should eq(nil)
      foo.ohai = :blearg
      foo.ohai.should eq(:blearg)
    end
  end
end
