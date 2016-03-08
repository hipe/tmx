module Skylab::TestSupport

  module DocTest

    class Actors_::Infer_business_module_name_loadlessly  # introduction at [#027]

      Callback_::Actor.methodic self, :simple, :properties,

        :property, :line_upstream,
        :property, :path,
        :property, :on_event_selectively

      include Lazy_Selective_Event_Methods_

      class << self

        def _call * a, & oes_p
          if 1 == a.length  # almost #[#ca-057]
            a.unshift :path
          end
          call_via_iambic a, & oes_p
        end

        alias_method :[], :_call
        alias_method :call, :_call

        private :new
      end  # >>

      def initialize & oes_p
        @line_upstream = nil
        @on_event_selectively = nil
        @path = nil

        if oes_p
          @on_event_selectively = oes_p
        end
      end

      def execute

        _fs = Home_.lib_.system.filesystem

        @tree = _fs.hack_guess_module_tree(
          :path, @path,
          :line_upstream, @line_upstream,
          & @on_event_selectively
        )

        @tree and via_tree
      end

      def via_tree
        init_against_symbol
        init_leaf_list
        via_leaves
      end

      def init_against_symbol
        _path = if COREFILE_TAIL__ == @path[ RANGE__ ]
          ::File.dirname @path
        else
          ::Pathname.new( @path ).sub_ext( EMPTY_S_ ).to_path
        end
        @against_i = Distill__[ ::File.basename _path ]
        nil
      end

      COREFILE_TAIL__ = "/#{ Autoloader_.default_core_file }"

      RANGE__ = - COREFILE_TAIL__.length .. -1

      def init_leaf_list

        dist_i_a = [] ; leaf_a = []

        @tree.children_depth_first do |node|
          if node.child_count.zero?
            leaf_a.push node
            dist_i_a.push Distill__[ node.value_x.last ]
          end
        end

        @leaf_dist_i_a = dist_i_a ; @leaf_a = leaf_a
        nil
      end

      def via_leaves
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
          if node.child_count.nonzero?
            branch_a.push node
            dist_i_a.push Distill__[ node.value_x.last ]
          end
        end

        @branch_dist_i_a = dist_i_a ; @branch_a = branch_a
      end

      Distill__ = Callback_.distill

      def matches_against dist_i_a, node_a
        against_i = @against_i
        d_a = []
        seen_h = {}
        dist_i_a.each_with_index do | distilled_i, idx |
          against_i == distilled_i or next
          _node = node_a.fetch idx
          _const_i = _node.value_x.last
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
          node.value_x.last
        end
        build_not_OK_event_with :ambiguous,
            :i_a, i_a, :path, @path do |y, o|
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
          leaf.value_x.last
        end

        _branch_i_a = @branch_a.map do |branch|
          branch.value_x.last
        end

        build_not_OK_event_with :not_found,
            :distilled, @against_i,
            :leaf_i_a, _leaf_i_a,
            :branch_i_a, _branch_i_a,
            :path, @path do |y, o|

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

        i_a = node.value_x.reverse
        node = node.parent
        x = node.value_x
        while x
          i_a.concat x.reverse
          node = node.parent
          x = node.value_x
        end

        i_a.reverse!

        i_a * CONST_SEP_
      end
    end
  end
end
