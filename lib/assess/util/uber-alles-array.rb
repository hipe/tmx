module Hipe
  module Assess
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
    # really simple associative array with strictness
    #
    class AssArr < Array

      #
      # make every array method protected except ones
      # that don't affect our @names property.
      #
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
      def push_with_key item, use_name
        if (use_name.nil? || use_name == '')
          fail "won't use empty or nil name: \"#{use_name.inspect}\""
        end
        if @names.include? use_name
          fail "already have \"#{use_name}\". use unset() first."
        end
        next_index = length
        push item
        @names[use_name] = next_index
        nil
      end
      def key? key
        @names.key? key
      end
      def at_key key
        fail("no item at key #{key}. use key?() first.") unless key?(key)
        idx = @names[key]
        self[idx]
      end
    end
  end
end
