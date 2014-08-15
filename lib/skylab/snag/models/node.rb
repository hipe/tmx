module Skylab::Snag

  module Models::Node

    class << self

      def build_collection manifest, client
        self::Collection__.new manifest, client
      end

      def build_controller fly=nil, client
        self::Controller__.new fly, client
      end

      def build_flyweight
        self::Flyweight__.new
      end

      def build_valid_query query_sexp, max_count, client
        self::Query__.new_valid query_sexp, max_count, client
      end

      def build_scan_from_lines normalized_line_producer
        self::Scan__.produce_scan_from_lines normalized_line_producer
      end

      def main_field_names
        self::Flyweight__.field_names
      end

      def max_lines_per_node
        MAX_LINES_PER_NODE__
      end
      MAX_LINES_PER_NODE__ = 2
    end

    Node_ = self
  end
end
