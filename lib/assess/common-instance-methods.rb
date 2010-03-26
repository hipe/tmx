module Hipe
  module Assess
    module CommonInstanceMethods
      #
      # a grab bag of the typical useful stuff
      #
      # You will see this included in perhaps dozens of modules
      # because we are avoiding monkeypatching
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
      def humanize underscore
        underscore.to_s.gsub(/_/, ' ')
      end
      def underscore? mixed
        /\A[_a-z0-9]+\Z/ =~ mixed
      end
      def fileize mixed
        mixed.to_s.gsub('_','-')
      end
      def truncate str, len=80, ellipsis='...'
        return str unless str.kind_of?(String) && str.length > len
        str[0..len-ellipsis.length] << ellipsis
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
        if respond_to?(name)
          fail("you tried to redefine #{name.inspect} "<<cute_stack(1))
        end
        meta.send(:define_method, name){value}
        nil
      end
      def redefine! name, value
        if ! respond_to?(name)
          fail("you can't redefine undefined #{name.inspect} "<<cute_stack(1))
        end
        meta.send(:define_method, name){value}
        nil
      end
      def meta
        class << self; self end
      end
      def oxford_comma items, sep=' and ', comma=', '
        return '()' if items.size == 0
        return items[0] if items.size == 1
        seps = [sep, '']
        seps.insert(0,*Array.new(items.size - seps.size, comma))
        items.zip(seps).flatten.join('')
      end
      def cute_stack mixed
        if mixed.kind_of?(Fixnum)
          row = caller[mixed]
        else
          row = mixed
        end
        p = parse_stack_row(row)
        ("when you were trying to #{humanize(p[:meth])} in "<<
        "#{p[:bn]}:#{p[:ln]}")
      end
      StackRow = /\A([^:]+):([^:]+):in `([^']+)'\Z/
      def parse_stack_row str
        if md = StackRow.match(str)
          {:path=>md[1], :bn=>File.basename(md[1]), :ln=>md[2], :meth=>md[3]}
        else
          {}
        end
      end
      Scalars = [NilClass, TrueClass, FalseClass, Fixnum, Float, String]
      def is_scalar? mixed
        Scalars.detect{|cls| mixed.kind_of?(cls)}
      end
    end
  end
end
