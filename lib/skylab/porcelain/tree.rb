module Skylab::Porcelain

  module Tree

    Fields__ = MetaHell::FUN.fields

    Fields_ = -> mod, *a do
      Fields__[ mod, *a ]
      mod.send :define_singleton_method, :[] do |*aa|
        new( * aa ).execute
      end
    end

    DEFAULT_PATH_SEPARATOR_ = '/'

    def self.new *a
      Node_.new( *a )
    end

    def self.from *a
      Node_.from( *a )
    end

    module ModuleMethods

      def from *a
        Tree::From_[ :client, self, *a ]
      end

      def path_separator
        Tree::DEFAULT_PATH_SEPARATOR_
      end
    end

    module InstanceMethods

      class Construction_
        Fields__[ self, :slug, :name_services ]
        attr_reader :slug, :name_services
      end

      def initialize *a
        o = Construction_.new( *a )
        if (( ns = o.name_services ))
          @node_id = ns.attach_notify self
          @name_services = ns
        end
        s = o.slug and append_isomorphic_key s
        @box_multi = nil
      end

      #  ~ as parent and/or child ~

      def path_separator
        self.class.path_separator
      end

      def is_leaf
        ! is_branch
      end

      def is_branch
        children_count.nonzero?
      end

      #  ~ as child, simple readers ~

      def isomorphic_key_count
        @name_services.count_keys @node_id
      end

      def any_slug
        slug if has_slug
      end

      def slug  # = `first_isomorphic_key`
        @name_services.fetch_first_key @node_id
      end

      def has_slug
        @name_services.count_keys( @node_id ).nonzero?
      end

      def last_isomorphic_key
        @name_services.fetch_last_key @node_id
      end

      #  ~ as child, simple mutators ~

      def prepend_isomorphic_key x
        @name_services.prepend_isomorphic_key_notify @node_id, x
        nil
      end

      def append_isomorphic_key x
        @name_services.append_isomorphic_key_notify @node_id, x
        nil
      end

      def name_services_change_notify otr
        @name_services = otr
        nil
      end

      # ~ as parent ~

      def has_children
        children_count.nonzero?
      end

      def children_count
        @box_multi ? @box_multi.count : 0
      end

      def fetch path
        Tree::Fetch_or_create_[ :client, self, :do_create, false, :path, path ]
      end

      def fetch_or_create *a  # ( may mutate )
        Tree::Fetch_or_create_[ :client, self, :do_create, true, *a ]
      end

      def fetch_first_child
        @box_multi.fetch_first_item
      end

      def [] k_x
        @box_multi[ k_x ]
      end

      def children
        @box_multi.get_enumerator
      end

      def get_child_scanner_p
        @box_multi.get_scanner_p
      end

      def get_some_child_scanner_p
        has_children ? get_child_scanner_p : MetaHell::EMPTY_P_
      end

      def to_text
        Tree::To_text_[ :client, self ]
      end

      def to_paths
        Tree::To_paths_[ :client, self ]
      end

      def longest_common_base_path
        if (( child = any_only_child ))
          res = [ child.slug ]
          ( r = child.longest_common_base_path ) and res.concat r
        end
        res
      end

      def any_only_child
        @box_multi and @box_multi.any_only_item
      end

      def fetch_only_child
        @box_multi.fetch_only_item
      end

      #  ~ as parent, name services ~

      def attach_notify node
        ( @box_multi ||= Tree::Box_Multi_.new ).add node
      end

      def detach_notify_and_release_keys_with_node_id node_id
        @box_multi.delete_and_release_keys_with_item_id node_id
      end

      def fetch_first_key node_id
        @box_multi.fetch_first_key_for node_id
      end

      def fetch_last_key node_id
        @box_multi.fetch_last_key_for node_id
      end

      def _fetch_key_a node_id
        @box_multi._fetch_key_a node_id
      end

      def count_keys node_id
        @box_multi.count_keys_for node_id
      end

      #  ~ as parent, mutators ~

      def prepend_isomorphic_key_notify node_id, x
        @box_multi.prepend_key_to_item x, node_id
        nil
      end

      def append_isomorphic_key_notify node_id, x
        @box_multi.append_key_to_item x, node_id
        nil
      end

      def merge_isomorphic_keys_notify node_id, a
        @box_multi.merge_keys_to_item a, node_id
        nil
      end

      #  ~ facet specific: merging (post-order, covered) ~

      def destructive_merge otr, *a
        Tree::Merge_[
          :client, self,
          :key_proc, -> node do
             node.last_isomorphic_key
           end,
          :other, otr, *a ]
      end

      def merge_attr_a
        self.class::MERGE_ATTR_A_  # #inherit-ok
      end

      MERGE_ATTR_A_ = [ :children ].freeze

      def destructive_merge_children_notify other, algo
        Tree::Merge_::Destructive_merge_children_[ self, other, algo ]
        nil
      end

      # #hacks-only -
      def _node_id ; @node_id end
      def _bm ; @box_multi end
      def _isomorphic_key_a
        @name_services._fetch_key_a @node_id
      end

      def transplant_notify_and_release_keys new_id, new_name_services
        ks = @name_services.
          detach_notify_and_release_keys_with_node_id @node_id
        @node_id = new_id ; @name_services = new_name_services
        ks
      end
    end

    class Node_
      extend ModuleMethods
      include InstanceMethods
    end
  end
end
