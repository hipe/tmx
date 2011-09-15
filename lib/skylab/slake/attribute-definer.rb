module Skylab
  module Slake
    module AttributeDefiner
      def attribute sym, opts={}
        @attributes ||= (dup_parent_attributes || {})
        @attributes[sym] ||= begin
          attr_accessor sym
          { :required => true }
        end
        @attributes[sym].merge!(opts)
      end
      def attributes
        unless @attributes
          @did_dup_parent_attributes ||= begin
            @attributes = dup_parent_attributes
            true
          end
        end
        @attributes
      end
      def dup_parent_attributes
        idx = 1
        parent_attributes = nil
        loop do
          case ancestors[idx]
          when NilClass
            break 2
          when Class
            parent_attributes = ancestors[idx].respond_to?(:attributes) ? ancestors[idx].attributes : nil
            break 2
          end
          idx += 1
        end
        parent_attributes ? parent_attributes.dup : {}
      end
    end
  end
end
