module ::Skylab::Porcelain

  module Attribute
    # Sorry for the confusion: some arbitrary set of name-value pairs,
    # e.g. "age" / "sex" / "location" of 55 / male / mom's basement,
    # let those be called 'actual attributes'.
    #
    # Now you might want to define 'formal attributes' that define some
    # superset of recognizable or allowable names (and possibly values)
    # for the actual attributes. For each such formal attribute,
    # this library lets you define one Attribute::Metadata that will
    # have metadata about each particular formal attributes.
    #
    # An associated set of such formal attributes is known here as an
    # `Attribute::Box` (think of it as an overwrought method signature,
    # or formal function parameters, or a regular expression etc, or
    # superset definition, or map-reduce operation, etc wat)
    #
    # To dig down even deeper, this library also lets you (requires you,
    # even) to stipulate the ways you define attributes themselves.
    #
    # Those are called `Attribute::MetaAttribute`s, and there is a box
    # for those too..
    #
    # So, in reverse, from the base: you make a box of meta-attributes.
    # This defines how you will define attributes. You can then,
    # (in each class for e.g.) define a box of attributes, using those
    # meta-attributes. Then when you have object of one such class,
    # it will itself have (actual) attributes.
    #
    # It may be confusing now, but note how lightweight the library is:
  end

  module Attribute::Definer
    def self.extended mod # per pattern [#sl-111]
      mod.extend Attribute::Definer::Methods
    end
  end


  module Attribute::Definer::Methods
    def attribute sym, meta_attributes=nil
      change_request = _attribute_meta_class.new sym
      meta = attributes.fetch( sym ) { nil }
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
      b = change_request.names - self.meta_attributes.names
      if b.length.nonzero?
        raise "meta attributes must first be declared: #{
          }#{ b.map(&:inspect) * ', ' }"
      end
      if meta
        meta.merge! change_request
      else
        method_defined? sym or attr_reader sym
        method_defined? "#{ sym }=" or attr_writer sym
        meta = attributes[sym] = change_request
      end
      change_request.each do |k, v|
        respond_to?(m = "on_#{ k }_attribute") and send m, sym, meta
      end
      nil
    end

    def _attribute_meta_class
      Attribute::Metadata
    end

    def attribute_meta_class klass
      define_singleton_method :_attribute_meta_class do klass end
    end

    def attributes
      @attributes ||= _parent_dup_2( :attributes ) { Attribute::Box.new }
    end

    def default_meta_attributes
      @default_meta_attributes ||= _parent_dup( :default_meta_attributes ) do
        Attribute::MetaAttribute::Box.new
      end
    end

    def import_meta_attributes mod
      block_given? and raise ::ArgumentError,
        "blocks not supported when importing meta attributes."
      if mod.const_defined? :InstanceMethods, false
        include mod::InstanceMethods
      end
      mod.meta_attributes.each do |k, meta|
        if respond_to?( meta.hook_name ) || meta_attributes.has?( k )
          fail "implement me: decide clobber behavior"
        end
        if meta.hook
          define_singleton_method meta.hook_name, & meta.hook
        end
        meta_attributes[k] = meta
      end
    end

    def meta_attribute *a, &b
      if b && a.length != 1
        raise ::ArgumentError,
          "with block form, only pass 1 meta_attribute, not #{ a.length }"
      end

      a.each do |attr_sym|
        case attr_sym
        when ::Symbol
          meta_attributes[attr_sym] ||= Attribute::MetaAttribute.new attr_sym
        when ::Module
          import_meta_attributes attr_sym, &b
        else
          fail "unspported type for meta attribute: #{ attr_sym.class }"
        end
      end

      if b
        attr_sym = a.last
        define_singleton_method "on_#{ attr_sym }_attribute" do |*aa| # posterity..
          instance_exec(* aa[0..(b.arity < 0 ? [aa.length - 1, 0].max : b.arity - 1)], &b) # as many or as few args
        end
        meta_attributes[attr_sym].hook = b
      end
      nil
    end

    def meta_attributes
      @meta_attributes ||= _parent_dup_2( :meta_attributes ) do
        Attribute::MetaAttribute::Box.new
      end
    end

    # @todo: clean up this redundancy @after:#100
    def _parent_dup attr_sym, &default
      if p = _parent_respond_to( attr_sym ) and a = p.send( attr_sym )
        a.dup
      else
        default.call
      end
    end

    def _parent_dup_2 attr_sym, &default
      if p = _parent_respond_to( attr_sym ) and a = p.send( attr_sym )
        a.dupe
      else
        default.call
      end
    end

    def _parent_respond_to method
      ancestors[ (self == ancestors.first ? 1 : 0) .. -1 ].detect do |a|
        ::Class === a and a.respond_to? method
      end
    end
  end

  class Attribute::Metadata < ::Hash

    def self.[] h                 # (basically converts a hash to
      new = self.new              # our native form.)
      h.each { |k, v| new[k] = v }
      new
    end

    alias_method :has?, :key?     # these changes appear
    undef_method :key?            # in one

    alias_method :names, :keys    # other place
    undef_method :keys            # in this file

    def initialize _=nil          # we ignore the name for now but u don't have
    end                           # to!
  end
                                               # (sister class: Parameter::Set)
  class Attribute::Box

    class << self
      alias_method :[], :new
    end

    def []= k, v
      @order.push( k ) if ! @hash.key?( k )
      @hash[k] = v
    end

    def dupe
      new = self.class.allocate
      new.send :initialize_duplicate, @order, @hash
      new
    end

    def each &block
      enum = ::Enumerator.new do |y|
        @order.each do |k|
          y << [k, @hash[k]]
        end
        nil
      end
      if block
        enum.each(& block)
      else
        enum
      end
    end

    def fetch key, &otherwise
      @hash.fetch key, &otherwise
    end

    alias_method :[], :fetch      # this is not like a hash, it is strict,
                                  # use `fetch` if you need hash-like softness

    def has? key
      @hash.key? key
    end

    def names
      @order.dup
    end


    # `with` is a map-reduce operation on a box.
    #
    # Use `with` to get a result hash whole elements are determined as
    # follows: For those attributes of this attribute box that have a
    # key? of `metaattribute`, the key (name) of the attribute is the
    # key in the result hash, and the value is the value of that attribute's
    # metaattribute called `metaattribute`.  It is exactly a map-reduce
    # operation.
    #
    # For a much needed example: with an attribute box that looks like:
    #
    #   Foo.attributes #=>
    #     { age: { default: 1 }, sex: { default: :banana }, location: {} }
    #
    # you get:
    #
    #   Foo.attributes.with(:default) #=> { age: 1, sex: :banana }
    #

    def with metaattribute
      ::Hash[
        @order.map do |k|
          m = @hash[k]
          [ k, m[metaattribute] ] if m.has? metaattribute
        end.compact
      ]
    end

  protected

    def initialize initial_a=nil
      @order = [ ]
      @hash = { }
      if initial_a
        initial_a.each do |k, v|
          self[ k ] = v
        end
      end
      nil
    end

    def initialize_duplicate order, hash
      @order = order.dup
      @hash = hash.class[ hash.map { |k, v| [k, v.dup] } ]
    end
  end

  class Attribute::MetaAttribute
    attr_reader :hook
    def hook= func
      @hook and fail "implement me: clobbering of existing hooks"
      @hook = func
    end

    def hook_name
      "on_#{ @name }_attribute"
    end

    def initialize name_sym
      @hook = nil
      @name = name_sym
    end

    attr_reader :name
  end
                                  # sneaky way to prove that we are sort of
                                  # serious about not subclassing core classes
                                  # frivolously or just for the novelty

  class Attribute::MetaAttribute::Box < ::Hash
    def dupe
      self.class[ map { |k, v| [k, v.dup] } ]
    end

    alias_method :has?, :key?     # these changes appear
    undef_method :key?            # in one

    alias_method :names, :keys    # other place
    undef_method :keys            # in this file
  end
end
