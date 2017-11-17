module Skylab::DocTest

  class AssetDocumentReadMagnetics_::Hack_Peek_Module_Name_via_Path  # introduction at [#006]
    # -
      Attributes_actor_.call( self,
        filesystem: nil,
        line_upstream: nil,
        path: nil,
        property: nil,
      )

      class << self

        def _call * a, & p
          if 1 == a.length  # almost #[#ca-057]
            a.unshift :path
          end
          call_via_iambic a, & p
        end

        alias_method :[], :_call
        alias_method :call, :_call

        private :new
      end  # >>

      def initialize & p
        @line_upstream = nil
        @listener = nil
        @path = nil
        if p
          @listener = p
        end
      end

      def execute
        ok = __resolve_tree
        ok && __init_against_symbol
        ok && __init_leaf_list
        ok && __via_leaves
      end

      def __resolve_tree

        _fs = Home_.lib_.system.filesystem

        tr = _fs.hack_guess_module_tree(
          :filesystem, @filesystem,
          :path, @path,
          :line_upstream, @line_upstream,
          & @listener
        )

        if tr
          @tree = tr ; ACHIEVED_
        else
          tr
        end
      end

      def __init_against_symbol

        _path = if COREFILE_TAIL__ == @path[ RANGE__ ]
          ::File.dirname @path
        else
          d = ::File.extname( @path ).length
          d.zero? ? @path : @path[ 0 ... - d ]
        end

        @_against_symbol = Distill__[ ::File.basename _path ]
        NIL_
      end

      COREFILE_TAIL__ = "/#{ Autoloader_::CORE_FILE }"

      RANGE__ = - COREFILE_TAIL__.length .. -1

      def __init_leaf_list

        dist_i_a = [] ; leaf_a = []

        @tree.children_depth_first do |node|
          if node.children_count.zero?
            leaf_a.push node
            dist_i_a.push Distill__[ node.value.last ]
          end
        end

        @leaf_dist_i_a = dist_i_a ; @leaf_a = leaf_a
        NIL_
      end

      def __via_leaves
        d_a = matches_against @leaf_dist_i_a, @leaf_a
        case 1 <=> d_a.length
        when  0 ; when_money @leaf_a.fetch d_a.first
        when  1 ; when_leaf_not_found
        when -1 ; when_ambiguous d_a.map{ |d| @leaf_a.fetch d }
        end
      end

      def when_leaf_not_found
        init_branch_list
        d_a = matches_against @branch_dist_i_a, @branch_a
        case 1 <=> d_a.length
        when  0 ; when_money @branch_a.fetch d_a.first
        when  1 ; when_branch_not_found
        when -1 ; when_ambiguous d_a.map { |d| @branch_a.fetch d }
        end
      end

      def init_branch_list

        dist_i_a = [] ; branch_a = []

        @tree.children_depth_first do |node|
          if node.children_count.nonzero?
            branch_a.push node
            dist_i_a.push Distill__[ node.value.last ]
          end
        end

        @branch_dist_i_a = dist_i_a ; @branch_a = branch_a
      end

      Distill__ = Common_::Distill

      def matches_against dist_i_a, node_a
        against_i = @_against_symbol
        d_a = []
        seen_h = {}
        dist_i_a.each_with_index do | distilled_i, idx |
          against_i == distilled_i or next
          _node = node_a.fetch idx
          _const_i = _node.value.last
          seen_h.fetch _const_i do
            seen_h[ _const_i ] = true
            d_a.push idx
          end
        end
        d_a
      end

      def when_ambiguous node_a
        maybe_send_event :error, :ambiguous do
          bld_ambiguous_event node_a
        end
      end

      def bld_ambiguous_event node_a

        i_a = node_a.map do |node|
          node.value.last
        end

        _event.build_not_OK_with(
          :ambiguous,
          :i_a, i_a,
          :path, @path,
        ) do |y, o|

          _s_a = o.i_a.map do |x|
            code x
          end

          y << "cannot resolve ambiguity: #{ and_ _s_a } #{
            }are all defined in #{ pth o.path }"
        end
      end

      def when_branch_not_found
        maybe_send_event :error, :not_found do
          bld_not_found_event
        end
      end

      def bld_not_found_event

        _leaf_i_a = @leaf_a.map do |leaf|
          leaf.value.last
        end

        _branch_i_a = @branch_a.map do |branch|
          branch.value.last
        end

        _event.build_not_OK_with(
          :not_found,
          :distilled, @_against_symbol,
          :leaf_i_a, _leaf_i_a,
          :branch_i_a, _branch_i_a,
          :path, @path,
        ) do |y, o|

          _l_s_a = o.leaf_i_a.map do |x|
            code x
          end

          _b_s_a = o.branch_i_a.map do |x|
            code x
          end

          y << "none of the leaf nodes nor branch nodes #{
            }look like #{ ick o.distilled } (leaf nodes: (#{
             }#{ and_ _l_s_a }), branch nodes: (#{
              }#{ and_ _b_s_a })) in #{ pth o.path }"

        end
      end

      def when_money node

        i_a = node.value.reverse
        node = node.parent
        x = node.value
        while x
          i_a.concat x.reverse
          node = node.parent
          x = node.value
        end

        i_a.reverse!

        i_a * CONST_SEP_
      end

      def _event
        @___EC ||= Event_Controller_.new( @listener )
      end
    # -
  end
end
