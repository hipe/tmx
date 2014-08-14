module Skylab::Snag

  module Models::Node

    require_relative 'node/enumerator'  # [#mh-035] preload bc toplevel exists

    class << self

      def build_collection manifest, client
        self::Collection__.new manifest, client
      end

      def main_field_names
        self::Flyweight__.field_names
      end

      def build_flyweight pathname
        self::Flyweight__.new pathname
      end

      def build_valid_search query_sexp, max_count, client
        self::Search__.new_valid query_sexp, max_count, client
      end

      def build_controller fly=nil, client
        self::Controller__.new fly, client
      end

      def max_lines_per_node
        MAX_LINES_PER_NODE__
      end
      MAX_LINES_PER_NODE__ = 2

    end
  end
end
