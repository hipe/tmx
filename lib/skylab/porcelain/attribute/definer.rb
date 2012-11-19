module ::Skylab::Porcelain

  module Attribute
    # sorry for the confusion: a MetaAttribute is an attribute an attribute
    # can have.  An Attribute::Meta is the abstract representation of an
    # attribute, that is, an attribute's name along with its meta-attribute
    # values.
  end


  module Attribute::Definer
    def self.extended mod # per pattern [#sl-111]
      mod.extend Attribute::Definer::Methods
    end
  end


  module Attribute::Definer::Methods
    def attribute sym, meta_attributes=nil
      change_request = _attribute_meta_class.new sym
      meta = attributes[sym]
      if ! meta
        change_request.merge! default_meta_attributes
      end
      if meta_attributes
        if meta
          meta_attributes.each do |k, v|
            if meta[k] != v
              change_request[k] = v
            end
          end
        else
          change_request.merge! meta_attributes
        end
      end
      (b = change_request.keys - self.meta_attributes.keys).any? and
        raise RuntimeError.new("meta attributes must first be declared: #{b.map(&:inspect) * ', '}")
      if meta
        meta.merge! change_request
      else
        method_defined?(sym) or attr_reader(sym)
        method_defined?("#{sym}=") or attr_writer(sym)
        meta = attributes[sym] = change_request
      end
      change_request.each do |k, v|
        respond_to?(m = "on_#{k}_attribute") and send(m, sym, meta)
      end
      nil
    end
    def _attribute_meta_class
      Attribute::Meta
    end
    def attribute_meta_class klass
      singleton_class.send(:define_method, :_attribute_meta_class) { klass }
    end
    def attributes
      @attributes ||= _parent_dup_2(:attributes) { Attribute::Box.new }
    end
    def default_meta_attributes
      @default_meta_attributes ||= _parent_dup(:default_meta_attributes) do
        Attribute::MetaAttribute::Box.new
      end
    end
    def import_meta_attributes mod
      block_given? and raise ArgumentError.new("blocks not supported when importing meta attributes.")
      if mod.const_defined?(:InstanceMethods)
        include mod::InstanceMethods
      end
      mod.meta_attributes.each do |k, meta|
        respond_to?(meta.hook_name) || meta_attributes.key?(k) and fail("implement me: decide clobber behavior")
        singleton_class.send(:define_method, meta.hook_name, & meta.hook) if meta.hook
        meta_attributes[k] = meta
      end
    end
    def meta_attribute *a, &b
      b && a.count != 1 and raise ArgumentError.new("with block form, only pass 1 meta_attribute, not #{a.count}")
      a.each do |attr_sym|
        case attr_sym
        when ::Symbol ; meta_attributes[attr_sym] ||=
                          Attribute::MetaAttribute.new attr_sym
        when ::Module ; import_meta_attributes(attr_sym, &b)
        else          ; fail("unspported type for meta attribute: #{attr_sym.class}")
        end
      end
      if b
        attr_sym = a.last
        singleton_class.send(:define_method, ("on_#{attr_sym}_attribute")) do |*aa|
          instance_exec(* aa[0..(b.arity < 0 ? [aa.length - 1, 0].max : b.arity - 1)], &b) # as many or as few args
        end
        meta_attributes[attr_sym].hook = b
      end
      nil
    end
    def meta_attributes
      @meta_attributes ||= _parent_dup_2(:meta_attributes) do
        Attribute::MetaAttribute::Box.new
      end
    end
    # @todo: clean up this redundancy @after:#100
    def _parent_dup attr_sym, &default
      if p = _parent_respond_to(attr_sym) and a = p.send(attr_sym)
        a.dup
      else
        default.call
      end
    end
    def _parent_dup_2 attr_sym, &default
      if p = _parent_respond_to(attr_sym) and a = p.send(attr_sym)
        a.duplicate
      else
        default.call
      end
    end
    def _parent_respond_to method
      ancestors[(self == ancestors.first ? 1 : 0) ..-1].detect { |a| a.kind_of?(Class) and a.respond_to?(method) }
    end
  end


  class Attribute::Meta < ::Hash
    def initialize _ # ignore the attribute name for this one!
    end
  end


  module Attribute::Hash_InstanceMethods
    def duplicate
      self.class[ * map{ |k, v| [k, v.dup] }.flatten(1) ]
    end
  end


  class Attribute::Box < ::Hash
    include Attribute::Hash_InstanceMethods

    # For the attributes that have a key? of `metattribute` return a new hash
    # of the values of the metaattributes
    #
    # e.g. for an attribute set that looks like:
    #
    #   Foo.attributes #=> { age: { default: 1 }, sex: { default: :banana }, location: {} }
    #
    # you get:
    #
    #   Foo.attributes.with(:default) #=> { age: 1, sex: :banana }
    #
    def with metaattribute
      ::Hash[* map { |k, m| [k, m[metaattribute]] if m.key?(metaattribute) }.
             compact.flatten(1) ]
    end
  end


  class Attribute::MetaAttribute
    attr_reader :hook
    def hook= prok
      @hook and fail("implement me: clobbering of existing hooks")
      @hook = prok
    end
    def hook_name
      "on_#{@name}_attribute"
    end
    def initialize name_sym
      @hook = nil
      @name = name_sym
    end
    attr_reader :name
  end


  class Attribute::MetaAttribute::Box < ::Hash
    include Attribute::Hash_InstanceMethods
  end
end
