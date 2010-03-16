module Hipe
  module Assess
    module StrictAttrAccessors

      def symbol_attr_accessor *names
        names.each do |name|
          setter_name = "#{name}="
          getter_name = name
          attr_name = "@#{name}"
          define_method getter_name do
            fail("not defined: #{attr_name}") unless
              instance_variable_defined?(attr_name)
            instance_variable_get attr_name
          end
          define_method setter_name do |x|
            fail("won't set \"#{name}\" to not symbol: #{x.inspect}") unless
              x.kind_of?(Symbol)
            instance_variable_set attr_name, x
          end
        end
      end

      def string_attr_accessor *names
        names.each do |name|
          setter_name = "#{name}="
          getter_name = name
          attr_name = "@#{name}"
          define_method getter_name do
            fail("not defined: #{attr_name}") unless
              instance_variable_defined?(attr_name)
            instance_variable_get attr_name
          end
          define_method setter_name do |x|
            fail("won't set \"#{name}\" to not string: #{x.inspect}") unless
              x.kind_of?(String)
            instance_variable_set attr_name, x
          end
        end
      end

      def boolean_attr_accessor *names
        names.each do |name|
          setter_name = "#{name}="
          getter_name = name
          getter_alias = "#{name}?"
          attr_name = "@#{name}"
          define_method getter_name do
            fail("not defined: #{attr_name}") unless
              instance_variable_defined?(attr_name)
            instance_variable_get attr_name
          end
          define_method setter_name do |x|
            fail("won't set \"#{name}\" to not bool: #{x.inspect}") unless
              x.kind_of?(TrueClass) or x.kind_of?(FalseClass)
            instance_variable_set attr_name, x
          end
          alias_method getter_alias, getter_name
        end
      end
    end
  end
end
