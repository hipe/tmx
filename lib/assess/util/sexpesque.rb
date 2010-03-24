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

      def pretty_print qq
        qq.group(1, 's[', ']') do
          qq.seplist(self) {|v| qq.pp v }
        end
      end

      def jsonesque
        JSON.pretty_generate(jsonable_struct)
      end

      def hash_like?
        res = hash_entry_like? && size == 2 ||
          (all_hash_entry_like? && unique_names?)
        res
      end

      def hash_entry_like?
        first.kind_of?(Symbol)
      end

      def all_hash_entry_like?
        res = size == 1 ||
        ! self[1..-1].detect{|x|!x.kind_of?(Sexpesque)||!x.hash_entry_like?}
        res
      end

      def unique_names?
        res = size == 1 || size == 2 ||
        (self[1..-1].map(&:first).uniq.size == size - 1)
        res
      end

      def jsonable_value
        if size == 1
          nil
        elsif size == 2
          (self[1].respond_to?(:jsonable_struct) ?
            self[1].jsonable_struct : self[1])
        elsif hash_like?
          h = {} # we tried # @todo 1.9
          self[1..-1].each do |x|
            unless x.respond_to?(:first)
              debugger; 'x'
            end
            h[x.first] = x.respond_to?(:jsonable_value) ?
              x.jsonable_value : x.to_json
          end
          h
        else
          self[1..-1] # the pretty tree is broken below here
        end
      end

      def jsonable_struct
        if hash_like?
          {first => jsonable_value}
        else
          debugger
          self.hash_like?
          self # pretty tree broken below this node
        end
      end

      def [](mixed)
        if mixed.kind_of?(Fixnum) || mixed.kind_of?(Range)
          super(mixed)
        else
          find_node(mixed)
        end
      end

      def []=(key,mixed)
        if mixed.kind_of?(Fixnum)
          super(mixed)
        else
          if idx = first_index(key)
            self[idx][2..-1] = nil
            self[idx][1] = mixed
          else
            self.push self.class[key,*mixed]
          end
          nil
        end
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
