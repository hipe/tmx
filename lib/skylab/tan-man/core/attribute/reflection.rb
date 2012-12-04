module Skylab::TanMan::Core::Attribute

  module Reflection
    # (If this settles down it will get pushed up.)
  end

  module Reflection::InstanceMethods
    # The default attribute definer for a typical object is its ordinary
    # class.  In some cases -- e.g. if you are dealing with a class or module
    # object and want to use attribute definer for *that* -- you will want to
    # redefine this method to return the singleton class instead, for
    # reflection to work (which is required for some kind of meta-attribute
    # setters, etc)

    def attribute_definer
      self.class
    end

    def attributes
      Reflection::Enumerator.new self
    end
  end


  class Reflection::Enumerator < ::Enumerator

    def to_h
      ::Hash[ to_a ]
    end

    def initialize o
      super() do |y|
        a = o.attribute_definer.attributes
        a.each do |k, h|
          y << [k, obj.send(k)]   # *very* experimental interface
        end
      end
    end
  end
end
