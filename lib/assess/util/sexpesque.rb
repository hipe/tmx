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

      # this assumes name-value pairs!
      def my_to_json_as_list indent
        child_indent = increment_indent(indent)
        str = ''
        my_to_json_children(str, 0..size-1, child_indent)
        str
      end

      def my_to_json indent=''
        unless self[0].kind_of?(Symbol)
          return my_to_json_as_list(indent)
        end
        str = "#{self[0].to_json}: "
        child_indent = increment_indent(indent)
        if size == 2
          item = self[1]
          if item.respond_to?(:my_to_json)
            str << item.my_to_json(indent)
          else
            str << item.to_json
          end
        else
          my_to_json_children(str, (1..size-1), child_indent)
        end
        str
      end

      def [](mixed)
        if mixed.kind_of?(Fixnum)
          super(mixed)
        else
          find_node(mixed)
        end
      end

      # thanks ryan
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

      # thanks ryan
      def find_nodes name
        find_all { |node| node.kind_of?(Sexpesque) && node.first == name }
      end

    private

      def increment_indent(indent)
        "#{indent} "
      end

      def my_to_json_children str, range, indent
        str << "{"
        final = size-1
        child_indent = increment_indent(indent)
        range.each do |idx|
          item = self[idx]
          if item.respond_to?(:my_to_json)
            str << "\n#{indent}" << item.my_to_json(child_indent)
          else
            str << item.to_json
          end
          if idx == final
          else
            str << ','
          end
        end
        str << '}'
      end
    end
  end
end
