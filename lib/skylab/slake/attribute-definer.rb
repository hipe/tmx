module Skylab
  module Slake
    module AttributeDefiner
      def attribute sym, opts={}
        attributes[sym] ||= begin
          attr_accessor sym
          { :required => true }
        end
        attr_meta = @attributes[sym].merge!(opts)
        attr_meta.key?(:default) and defaults[sym] = attr_meta[:default]
        attr_meta
      end
      def attributes
        @attributes ||= _dup_closest_parent_attribute(:attributes) || {}
      end
      def defaults
        @defaults ||= _dup_closest_parent_attribute(:defaults) || {}
      end
      def _dup_closest_parent_attribute attrib
        ( p = _closest_parent_to_respond_to(attrib) and p.send(attrib).dup ) or nil
      end
      def _closest_parent_to_respond_to method
        ancestors[1..-1].detect { |a| a.kind_of?(Class) and a.respond_to?(method) }
      end
    end
  end
end

