module Skylab::Snag

  module Models::Node

    require_relative 'node/enumerator'  # [#mh-035] preload bc toplevel exists

    class << self

      def build_collection client, manifest
        self::Collection__.new client, manifest
      end

      def main_field_names
        self::Flyweight__.field_names
      end

      def build_flyweight client, pathname
        self::Flyweight__.new client, pathname
      end

      def build_valid_search client, max_count, query_sexp
        self::Search__.new_valid client, max_count, query_sexp
      end

      def build_controller client, fly=nil
        self::Controller__.new client, fly
      end

      def max_lines_per_node
        MAX_LINES_PER_NODE__
      end
      MAX_LINES_PER_NODE__ = 2

    end
  end
end
