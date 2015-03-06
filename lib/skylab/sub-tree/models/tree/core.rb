module Skylab::SubTree

  # Models = ::Module.new  # #change-this-at-step:10

  module Models::Tree

    class << self

      def enhance_with_module_methods_and_instance_methods mod

        mod.extend Module_Methods__
        mod.include Instance_Methods__ ; nil
      end

      def from shape_symbol, x
        Node__.from shape_symbol, x
      end

    end  # >>

    module Module_Methods__

      def from sym, x

        s = sym.id2name

        ia = Tree_::Input_Adapters__.const_get(
          :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"  # :+#actor-case
        ).new

        ia.mixed_upstream = x
        ia.node_class = self
        ia.produce_tree
      end

      def path_separator
        DEFAULT_PATH_SEPARATOR___
      end
    end

    DEFAULT_PATH_SEPARATOR___ = ::File::SEPARATOR

    class Node_Construction___

      Callback_::Actor.call self, :properties,
        :name_services, :slug

      attr_reader :name_services, :slug

      class << self
        def new_via_iambic x_a, & oes_p  # :+[#ca-063]
          new do
            oes_p and accept_selective_listener_proc oes_p
            process_iambic_fully x_a
          end
        end
      end  # >>
    end

    module Instance_Methods__

      def initialize * x_a  # yes globbed, we construct these by hand

        @box_multi = nil  # often re-written when below

        if x_a.length.nonzero?
          nc = Node_Construction___.new_via_iambic x_a

          ns = nc.name_services
          if ns
            @node_id = ns.attach_notify self
            @name_services = ns
          end

          sl = nc.slug
          if sl
            append_isomorphic_key sl
          end
        end

        NIL_
      end

      def members
        [ :any_slug, :children, :children_count, :fetch, :has_children,
          :has_slug, :is_branch, :node_payload, :slug, :to_child_stream ]
      end

      # ~ exposures to high-level expression adapters & related (experimental)

      def to_classified_stream_for modality_symbol, * x_a

        x_a.push :node, self

        s = modality_symbol.id2name  # :+#actor-case

        Tree_::Expression_Adapters__.const_get(

          :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }", false

        )::Actors::Build_classified_stream.call_via_iambic x_a
      end

      def to_classified_stream

        Tree_::Actors__::Build_classified_stream.new( self ).execute
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
        if has_slug
          slug
        end
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

        Tree_::Small_Time_Actors__::Fetch_or_create.with(

          :path, path,
          :else_p, else_p,
          :do_not_create,
          :node, self )
      end

      def fetch_or_create * x_a, & x_p  # `x_p` currently not used

        Tree_::Small_Time_Actors__::Fetch_or_create.with(

          :create_if_necessary,
          :node, self,
          * x_a, & x_p )
      end

      def fetch_first_child
        @box_multi.fetch_first_item
      end

      def child_at_position idx
        @box_multi.item_at_position idx
      end

      def [] k_x
        @box_multi[ k_x ]
      end

      def children
        @box_multi.get_enumerator
      end

      def to_child_stream
        Callback_.stream( & get_some_child_stream_p )
      end

      def get_some_child_stream_p
        has_children ? get_child_stream_p : EMPTY_P_
      end

      def get_child_stream_p
        @box_multi.get_stream_p
      end

      def longest_common_base_path
        child = any_only_child
        if child
          y = [ child.slug ]
          child.__longest_common_base_path_into y
          y
        end
      end

      def __longest_common_base_path_into y
        child = any_only_child
        if child
          y.push child.slug
          child.__longest_common_base_path_into y
        end
      end

      def any_only_child
        @box_multi and @box_multi.any_only_item
      end

      def fetch_only_child
        @box_multi.fetch_only_item
      end

      #  ~ as parent, name services ~

      def attach_notify node
        @box_multi ||= Tree_::Models__::Box_Multi.new
        @box_multi.add node
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
        Tree_::Merge_[
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
        Tree_::Merge_::Destructive_merge_children_[ self, other, algo ]
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

    # (immediately after instance methods close we do the below)

    Tree_ = self

    class Node__

      Tree_.enhance_with_module_methods_and_instance_methods self
    end

    Autoloader_[ Sessions_ = ::Module.new ]
  end
end
