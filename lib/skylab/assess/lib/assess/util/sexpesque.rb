module Hipe
  module Assess
    class Sexpesque < Array
      #
      # quick and dirty way to represent stuff like s-expressions
      # and output it as json-like.  Inspired by sexp
      #

      def initialize *args
        super(args)
      end

      def self.[](*args)
        self.new(*args)
      end

      def [](mixed)
        if mixed.kind_of?(Fixnum) || mixed.kind_of?(Range)
          super(mixed)
        else
          find_node(mixed)
        end
      end

      # careful!
      def has_key? mixed
        first_index mixed
      end

      def []=(key,mixed)
        if mixed.kind_of?(Fixnum)
          super(mixed)
        else
          if idx = first_index(key)
            self[idx][2..-1] = nil
            self[idx][1] = mixed
          else
            self.push self.class[key,mixed]
          end
          nil
        end
      end

      def jsonesque
        JSON.pretty_generate(jsonesque_struct)
      end

      class << self
        def hash_rhs mixed
          if mixed.kind_of?(Sexpesque)
            mixed.hash_rhs
          else
            fail 'do me'
          end
        end

        def hash mixed
          return false unless mixed.kind_of?(Sexpesque)
          return false unless mixed.first_element_is_keylike?
          mixed.hash
        end

        def jsonesque_struct mixed
          mixed.respond_to?(:jsonesque_struct)? mixed.jsonesque_struct : mixed
        end
      end

      def hash
        fail("not first_element_is_keylike?") unless first_element_is_keylike?
        first
      end

      def hash_rhs
        if first_element_is_keylike?
          if noninitial_children_have_unique_keys?
            hash_for_these_ones(1..size-1)
          elsif looks_like_a_hash_key_value_pair?
            self.class.jsonesque_struct self[1]
          else # we are probably a named array like s[:messages, 'foo','bar']
            self[1..size-1]
          end
        else
          fail 'do me'
        end
      end

      KeyLike = [String,Symbol]
      def first_element_is_keylike?
        KeyLike.include? first.class
      end

    private

      def jsonesque_struct
        if first_element_is_keylike? && noninitial_children_have_unique_keys?
          hash_with_one_element_whose_value_is_hash
        elsif all_children_have_unique_keys?
          straight_up_hash
        elsif all_children_have_keys?
          squozen_hash
        elsif first_element_is_keylike?
          hash_with_one_element_whose_remainder_is_pruned_struct
        else
          never
        end
      end

      def looks_like_a_hash_key_value_pair?
        first_element_is_keylike? && size == 2
      end

      def noninitial_children_have_unique_keys?
        return true if size < 2
        these_children_have_unique_keys?(1..size-1)
      end

      def all_children_have_unique_keys?
        these_children_have_unique_keys?(0..size-1)
      end

      def all_children_have_keys?
        ! any?{|v| false == self.class.hash(v) }
      end

      def these_children_have_unique_keys? range
        keys = {}
        key = nil
        self[range].each do |mixed|
          return false unless (key = self.class.hash(mixed))
          return false if keys.has_key?(key)
          keys[key] = true
        end
        true
      end

      def hash_with_one_element_whose_value_is_hash
        hashtable = hash_for_these_ones(1..size-1)
        {hash => hashtable}
      end

      def hash_with_one_element_whose_remainder_is_pruned_struct
        resp = {hash => pruned_struct_for(1..size-1)}
        resp
      end

      def pruned_struct_for range
        them = self[range]
        if them.size == 0
          nil
        elsif them.size == 1
          them[0]
        else
          them
        end
      end

      def squozen_hash
        hashtable = hash_for_these_ones(0..size-1)
        hashtable
      end

      def straight_up_hash
        hash_for_these_ones(0..size-1)
      end

      def hash_for_these_ones range
        h = {}
        self[range].each do |mixed|
          h[self.class.hash(mixed)] = self.class.hash_rhs(mixed)
        end
        h
      end

      def first_index name
        found = nil
        each_with_index do |item, idx|
          if item.kind_of?(Array) && item.first == name
            found = idx
            break
          end
        end
        found
      end

      def find_node name
        matches = find_nodes name

        case matches.size
        when 0 then
          nil
        when 1 then
          matches.first
        else
          fail("multiple nodes for #{name} were found in #{inspect}")
        end
      end

      def find_nodes name
        find_all { |node| node.kind_of?(Array) && node.first == name }
      end
    end
  end
end
