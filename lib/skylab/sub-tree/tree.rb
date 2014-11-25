module Skylab::SubTree

  module Tree

    def self.enhance_with_module_methods_and_instance_methods mod
      mod.extend Module_Methods__
      mod.include Instance_Methods__ ; nil
    end

    Entity_ = -> client, _props_, * i_a do
      :properties == _props_ or raise ::ArgumentError, "'properties' not '#{ _fields_ }'"
      SubTree_._lib.funcy_globless client
      def client.call_via_iambic x_a
        new( x_a ).execute
      end
      SubTree_._lib.basic_fields.with :client, client,
        :absorber, :initialize,
        :field_i_a, i_a ; nil
    end

    DEFAULT_PATH_SEPARATOR_ = '/'.freeze

    def self.new *a
      Node_.new( *a )
    end

    def self.from *a
      Node_.from_mutable_args a
    end

    module Module_Methods__

      def from * a
        from_mutable_args a
      end

      def from_mutable_args a
        a.unshift :client, self
        Tree::From_[ a ]
      end

      def path_separator
        Tree::DEFAULT_PATH_SEPARATOR_
      end
    end

    module Instance_Methods__

      class Construction_
        Entity_[ self, :properties, :slug, :name_services ]
        attr_reader :slug, :name_services
      end

      def initialize * x_a  # yes globbed, we construct these by hand
        o = Construction_.new x_a
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

      def first_isomorphic_key
        @name_services.fetch_first_key @node_id
      end

      def slug
        first_isomorphic_key
      end

      def has_slug
        @name_services.count_keys( @node_id ).nonzero?
      end

      def is_under_isomorphic_key key_x
        @name_services.is_child_under_key @node_id, key_x
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

      def add_isomorphic_key_with_metakey x, mk_x
        @name_services.add_metakeyed_key_notify @node_id, mk_x, x
      end

      def index_isomorphic_key_with_metakey x, mk_x
        @name_services.add_metakey_to_existing_key_notify @node_id, mk_x, x
      end

      def fetch_isomorphic_key_with_metakey mk_x, &blk
        @name_services.
          fetch_isomorphic_key_with_metakey_notify @node_id, mk_x, blk
      end

      def detach_and_release_keyset
        @name_services.detach_and_release_keyset_notify @node_id
      end

      def set_node_payload x
        @node_payload = x ; nil
      end

      attr_reader :node_payload

      # ~ as parent ~

      def has_children
        children_count.nonzero?
      end

      def children_count
        @box_multi ? @box_multi.count : 0
      end

      def fetch path, & else_p
        Tree::Fetch_or_create_[ :client, self, :do_create, false,
          :else_p, else_p, :path, path ]
      end

      def fetch_or_create *a  # ( may mutate )
        Tree::Fetch_or_create_[ :client, self, :do_create, true, *a ]
      end

      def fetch_first_child
        @box_multi.fetch_first_item
      end

      def fetch_child_at_index idx
        @box_multi.fetch_item_at_index idx
      end

      def [] k_x
        @box_multi[ k_x ]
      end

      def children
        @box_multi.get_enumerator
      end

      def get_child_stream_p
        @box_multi.get_stream_p
      end

      def get_some_child_stream_p
        has_children ? get_child_stream_p : EMPTY_P_
      end

      def to_text
        Tree::To_text_[ :client, self ]
      end

      def to_paths
        Tree::To_paths_[ :client, self ]
      end

      def get_traversal_stream *a
        Tree::Traversal::Scanner_[ self, *a ]
      end

      alias_method :get_traversal_stream, :get_traversal_stream

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

      def detach_and_release_keyset_notify node_id
        @box_multi.delete_item_and_release_keyset_for node_id
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

      def is_child_under_key node_id, key_x
        @box_multi.is_item_under_key node_id, key_x
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

      def add_metakeyed_key_notify node_id, mk_x, x
        @box_multi.add_metakeyed_key_to_item mk_x, x, node_id
      end

      def add_metakey_to_existing_key_notify node_id, mk_x, x
        @box_multi.add_metakey_to_existing_key_of_item mk_x, x, node_id
      end

      def merge_keys_notify node_id, keys
        @box_multi.merge_keyset_to_item keys, node_id
      end

      def fetch_isomorphic_key_with_metakey_notify node_id, mk_x, blk
        @box_multi.with_metakey_fetch_node_key mk_x, node_id, &blk
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

      MERGE_ATTR_A_ = [ :children, :keys ].freeze

      def destructive_merge_children_notify other, algo
        Tree::Merge_::Destructive_merge_children_[ self, other, algo ]
        nil
      end

      def destructive_merge_keys_notify otr, algo
        ks = otr.detach_and_release_keyset
        @name_services.merge_keys_notify @node_id, ks
      end

      # #hacks-only -
      def _node_id ; @node_id end
      def _bm ; @box_multi end
      def _isomorphic_key_a
        @name_services._fetch_key_a @node_id
      end
      alias_method :_iks, :_isomorphic_key_a

      def transplant_notify_and_release_keyset new_id, new_name_services
        ks = @name_services.detach_and_release_keyset_notify @node_id
        @node_id = new_id ; @name_services = new_name_services
        ks
      end

      # #hacks-only - from another mother
      def multibox_ownership_transfer_notify wat
        @name_services = wat
        nil
      end
    end

    class Node_
      Tree.enhance_with_module_methods_and_instance_methods self
    end
  end
end
