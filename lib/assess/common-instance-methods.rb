module Hipe
  module Assess
    module CommonInstanceMethods
      #
      # a grab bag of the typical useful stuff
      #
      def self.[](mixed); mixed.extend(self); mixed; end

      def camelize underscores
        underscores.to_s.gsub(/_([a-z]?)/){$1.upcase}
      end
      def titleize mixed
        mixed.to_s.gsub(/\A(.?)/){$1.upcase}
      end
      def underscore mixed
        mixed.to_s.gsub(/([a-z])(?=[A-Z])/){ "#{$1.downcase}_" }.downcase
      end
      def underscore? mixed
        /\A[_a-z0-9]+\Z/ =~ mixed
      end
      def fileize mixed
        mixed.to_s.gsub('_','-')
      end
      def assert_type param_name, thing, type
        unless thing.kind_of? type
          meth = method_name_from_call_stack_item caller[0]
          msg = ("#{meth} - #{param_name} must be #{type}, had"<<
            " #{thing.class}")
          fail(msg)
        end
        nil
      end
      MethodNameRe = /`([^']+)'\Z/
      def method_name_from_call_stack_item row
        MethodNameRe.match(row)[0]
      end
      def class_basename kls
        Assess.class_basename kls.to_s
      end
      def string_to_constant str
        klass = str.split(/::/).inject(Object) { |k, n| k.const_get n }
        klass
      end
      def flail *args
        raise UserFail.new(*args)
      end
      def def! name, value
        fail('no') if respond_to?(:name)
        class << self; self end.send(:define_method, name){value}
        self
      end
      def oxford_comma items, sep=' and ', comma=', '
        return '()' if items.size == 0
        return items[0] if items.size == 1
        seps = [sep, '']
        seps.insert(0,*Array.new(items.size - seps.size, comma))
        items.zip(seps).flatten.join('')
      end
    end
  end
end
