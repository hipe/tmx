module Skylab
end

module Skylab::Porcelain
  module AttributeDefiner
    def attribute sym, meta_attributes=nil
      change_request = {}
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
        @_im ||= instance_methods # think of all the side-effects this has:
          # it takes a snapshot of all instance methods all the way up the chain only the
          # first time you declare an attribute on a given module
        @_im.include?(sym) or attr_reader sym
        @_im.include?(:"#{sym}=") or attr_writer sym
        meta = attributes[sym] = change_request
      end
      change_request.each do |k, v|
        respond_to?(m = "on_#{k}_attribute") and send(m, sym, meta)
      end
      nil
    end
    def attributes
      @attributes ||= _parent_dup_2(:attributes) { { } }
    end
    def default_meta_attributes
      @default_meta_attributes ||= _parent_dup(:default_meta_attributes) { { } }
    end
    def import_meta_attributes mod
      block_given? and raise ArgumentError.new("blocks not supported when importing meta attributes.")
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
        when Symbol ; meta_attributes[attr_sym] ||= MetaAttribute.new(attr_sym)
        when Module ; import_meta_attributes(attr_sym, &b)
        else        ; fail("unspported type for meta attribute: #{attr_sym.class}")
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
      @meta_attributes ||= _parent_dup_2(:meta_attributes) { {} }
    end
    def _parent_dup attr_sym, &default
      if p = _parent_respond_to(attr_sym) and a = p.send(attr_sym)
        a.dup
      else
        default.call
      end
    end
    def _parent_dup_2 attr_sym, &default
      if p = _parent_respond_to(attr_sym) and a = p.send(attr_sym)
         Hash[ * a.map{ |k, v| [k, v.dup] }.flatten(1) ]
      else
        default.call
      end
    end
    # we may have to broaden this definition one day!
    def _parent_respond_to method
      ancestors[1..-1].detect { |a| a.kind_of?(Class) and a.respond_to?(method) }
    end
  end
end

module Skylab::Porcelain::AttributeDefiner
  class MetaAttribute
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
end

