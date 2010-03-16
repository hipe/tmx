module Hipe
  module Assess
    module Proto
      #
      # Two sorta unrelated array-like things ended up in here
      #


      #
      # classes can register all of their instances easily
      #
      module UberAllesArray
        def self.extended klass
          klass.instance_variable_set('@all', [] ) unless
            klass.instance_variable_defined?('@all')
          class << klass
            attr_accessor :all
          end
        end
        def register obj
          id = all.length
          all[id] = obj
          id
        end
      end


      #
      # strictness, child must define name()
      #
      class AssArr < Array
        except = %w( [] size each inspect pretty_print )
        all = ancestors[1].instance_methods(false)
        these = all - except
        these.each do |name|
          protected name
        end
        def initialize()
          super()
          @names = {}
        end
        def push item
          if @names.include? item.name
            fail "already have \"#{item.name}\". use unset() first"
          end
          super item
          @names[item.name] = length - 1
          nil
        end
      end
    end
  end
end
