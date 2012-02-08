module Skylab ; end

module Skylab::Slake
  module AttributeDefiner
    def attribute sym, meta_attributes=nil
      change_request = {}
      current_meta = attributes[sym]
      if ! current_meta
        change_request.merge! default_meta_attributes
      end
      if meta_attributes
        if current_meta
          meta_attributes.each do |k, v|
            if current_meta[k] != v
              change_request[k] = v
            end
          end
        else
          change_request.merge! meta_attributes
        end
      end
      (b = change_request.keys - self.meta_attributes.keys).any? and
        raise RuntimeError.new("meta attributes must first be declared: #{b.map(&:inspect) * ', '}")
      if current_meta
        current_meta.merge! change_request
      else
        @_im ||= instance_methods # think of all the side-effects this has:
          # it takes a snapshot of all instance methods all the way up the chain only the
          # first time you declare an attribute on a given module
        @_im.include?(sym) or attr_reader sym
        @_im.include?(:"#{sym}=") or attr_writer sym
        current_meta = attributes[sym] = change_request
      end
      change_request.each do |k, v|
        respond_to?(m = "on_#{k}_attribute") and send(m, sym, current_meta)
      end
      nil
    end
    def attributes
      @attributes ||= _parent_dup_2(:attributes) { { } }
    end
    def default_meta_attributes
      @default_meta_attributes ||= _parent_dup(:default_meta_attributes) { { } }
    end
    def meta_attribute *a
      a.each do |attr_sym|
        meta_attributes[attr_sym] ||= AttributeMeta.new(attr_sym)
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

module Skylab::Slake::AttributeDefiner
  class AttributeMeta
    def initialize name_sym
      @name = name_sym
    end
    attr_reader :name
  end
end

