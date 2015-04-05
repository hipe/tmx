module Skylab::Snag

  module Models::Node

    class << self

      def build_collection manifest, _API_client
        self::Collection__.new manifest, _API_client
      end

      def build_controller delegate, _API_client
        self::Controller__.new delegate, _API_client
      end

      def build_flyweight
        self::Flyweight__.new
      end

      def build_valid_query query_sexp, max_count, delegate
        self::Query__.normal query_sexp, max_count, delegate
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

    class Silo_Daemon < ::Object

      def initialize _API_client, _model_class
        @models = _API_client.models
      end

      def collection_for working_dir, & err_p
        @models.manifests.if_manifest_for_working_dir working_dir, -> mani do
          mani.node_collection
        end, err_p
      end
    end

    Node_ = self
  end
end
