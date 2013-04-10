module Hipe
  module Assess
    module Const
      #
      # these used to be defined closer to where they are used
      # but we had problems with modules that wanted to include
      # CommonInstanceMethods but needed to keep their internal
      # namespace clear
      #

      Scalars = [NilClass, TrueClass, FalseClass, Fixnum, Float, String]
      StackRow = /\A([^:]+):([^:]+)(?::in `([^']+)')?\Z/
      MethodName = /`([^']+)'\Z/

      #
      # split on any dot that has one or more not dots after it till the end
      # "foo.tgz" => ['foo','tgz']  "foo.tar.gz"=>['foo.tar','gz']
      #    "foo"=>["foo"]
      #
      ExtRe = /\.(?=[^\.]+$)/

    end
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
      def underscore_lossy mixed
        s = mixed.dup # underscore(mixed)
        s.gsub!(/[\(\)'"]/, '').gsub!(/[^_a-z0-9]/,'_')
        s
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
      def method_name_from_call_stack_item row
        Cont::MethodName.match(row)[0]
      end
      def class_basename kls
        Assess.class_basename kls.to_s
      end
      def string_to_constant str
        klass = str.split(/::/).inject(Object) { |k, n| k.const_get n }
        klass
      end
      def flail *args, &block
        raise UserFail.new(*args, &block)
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
        p = trace_parse(row)
        ("when you were trying to #{humanize(p[:meth])} in "<<
        "#{p[:bn]}:#{p[:ln]}")
      end
      def trace_parse str
        if md = Const::StackRow.match(str)
          path, line, method = md.captures
          bn = File.basename(path)
          h = {:path=>path, :line=>line, :method=>method, :basename=>bn}
          {:method=>:meth,:basename=>:bn,:line=>:ln}.each{|(a,b)| h[b] = h[a]}
          h
        else
          {}
        end
      end
      def is_scalar? mixed
        Const::Scalars.detect{|cls| mixed.kind_of?(cls)}
      end
    end
    Common = CommonInstanceMethods[Object.new]
    module CommonModuleMethods
      include CommonInstanceMethods
      def const_accessor *a
        a.each do |k|
          const_name = titleize(camelize(k))
          meta.send(:define_method, k){const_get(const_name)}
        end
      end
    end
  end
end
