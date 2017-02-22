module Skylab::Snag

  class Models_::ToDo

    Modalities = ::Module.new  # assert creation because registered stowaway

    Modalities::CLI = ::Module.new  # same

    module Modalities::CLI

      Actions = ::Module.new  # same

      class Actions::ToStream < Brazen_::CLI::Action_Adapter

        # we hack properties, do custom event handling, and hack expression

        # ~ override parrent to create a custom dispatcher off of bound

        def initialize unbound, boundish

          super nil, nil

          @be_verbose = false
          @bound = unbound.new boundish.kernel do | * i_a, & ev_p |

            if :error == i_a.first
              receive_uncategorized_emission i_a, & ev_p
            else
              i_a_ = i_a[ 2 .. -1 ].reverse
              :info == i_a.first or i_a_.push i_a.first
              i_a_.push i_a.fetch 1
              _m = :"__receive__#{ i_a_ * UNDERSCORE_ }__"
              send _m, i_a, & ev_p
            end
          end

          __init_counts
        end
        def __init_counts
          d = 0
          @skip_match_count_proc = -> { d }
          @inc  = -> do
            d += 1
          end
        end

        def _increment_count _
          @inc[]
          NIL_
        end

        # ~ we divide and mutate the formal properties, adding our own

        def init_properties

          bp = @bound.formal_properties
          fp = bp.to_mutable_box_like_proxy

          cls = @bound.class::Property

          prp = cls.with :name_symbol, :verbose, :flag
          fp.add prp.name_symbol, prp

          prp = cls.with :name_symbol, :tree,
            :parameter_arity, :zero_or_more,
            :argument_arity, :zero,
            :description, -> y do
              y << "`-t` for black & white, `-tt` for color"
            end
          fp.add prp.name_symbol, prp

          # @bound.change_formal_properties bp

          @back_properties = bp
          @front_properties = fp

          NIL_
        end

        def receive__tree__option _, prp
          increment_seen_count prp.name_symbol
          NIL_
        end

        def receive__verbose__option _, _
          @be_verbose = true
          NIL_
        end

        # ~ the mandatory (per our custom event dispatcher) event handlers

        def __receive__did_not_match__ i_a, & ev_p

          if @be_verbose
            receive_uncategorized_emission i_a, & ev_p
          else

            _increment_count :skip_match
            NIL_
          end
        end

        def __receive__find_command_args_event__ i_a, & ev_p

          if @be_verbose
            receive_uncategorized_emission i_a, & ev_p
          end

          NIL_
        end

        # ~ the conditionally custom expression behavior

        def bound_call_via_bound_call_from_back bc  # :+[#br-060]

          occurrences = @seen[ :tree ]
          if occurrences

            d = occurrences.seen_count or self._SANITY

            Common_::BoundCall.by do
              __express_as_tree d, bc
            end
          else
            bc
          end
        end

        def __express_as_tree prettiness_d, bc

          st = bc.receiver.send bc.method_name, * bc.args, & handle_event_selectively

          st and begin
            Magnetics_::TreeExpression_via_Arguments.with(
              :item_stream, st,
              :glyphset_category_symbol, :wide,  # narrow | wide
              :do_pretty, ( 1 < prettiness_d ),
              :skip_match_count_proc, @skip_match_count_proc,
              :info_byte_downstream, @resources.serr,
              :payload_byte_downstream, @resources.sout,
              & handle_event_selectively )

          end
        end

        # <- 2

    Magnetics_ = ::Module.new

    class Magnetics_::TreeExpression_via_Arguments

      Attributes_actor_.call( self,
        :item_stream,
        :glyphset_category_symbol,
        :do_pretty,
        :skip_match_count_proc,
        :info_byte_downstream,
        :payload_byte_downstream,
      )

      def execute

        @tree = Home_.lib_.basic::Tree.mutable_node.new
        populate_tree
        prune_tree
        resolve_line_stream
        @line_stream and flush
      end

      def populate_tree

        st = @item_stream
        tree = @tree
        count = 0

        st.each do | todo |  # it's a stream but we want the scope
          count += 1

          _path_a = todo.path.split( SEP__ ).push todo.lineno.to_s

          tree.touch_node _path_a, :leaf_node_payload_proc, -> do
            todo
          end
        end
        @item_count = count
        NIL_
      end

      def prune_tree

        node = @tree
        slug_s_a = nil

        begin

          node_ = node.any_only_child
          node_ or break
          s = node.slug
          if slug_s_a
            slug_s_a.push s
          else
            slug_s_a = []
            if s
              slug_s_a.push s  # only at root, allow root to have no slug
            end
          end
          node = node_
          redo
        end while nil

        if slug_s_a
          slug_s_a.push node.slug
          node.change_slug slug_s_a * SEP__
          @tree = node
        end

        NIL_
      end

      SEP__ = ::File::SEPARATOR

      def resolve_line_stream
        @line_stream = if @do_pretty
          Build_pretty_tree_lines_stream___[ @tree, @glyphset_category_symbol ]
        else
          Build_basic_tree_lines_stream___[ @tree, @glyphset_category_symbol ]
        end
      end

      def flush

        bd = @payload_byte_downstream
        st = @line_stream
        begin
          line = st.gets
          line or break
          bd.puts line
          redo
        end while nil

        d = @skip_match_count_proc[]
        _s = if d.nonzero?
          ", skipped #{ d } from grep"
        else
          ' total'
        end

        @info_byte_downstream.puts "(found #{ @item_count } to do's#{ _s })"

        ACHIEVED_
      end
    end

    class Build_basic_tree_lines_stream___ < Common_::Dyadic

      def initialize t, gs
        @glyphset = gs
        @tree = t
        @glyphset_category_symbol = :wide  # wide or narrow ..
      end

      def execute

        _st = @tree.to_classified_stream_for :text,
          :glyphset_identifier_x, @glyphset_category_symbol

        _st.map_by do | card |
          line_via_card card
        end
      end

      def line_via_card card
        prefix_s = card.prefix_string
        node = card.node
        s = "#{ prefix_s } #{ node.slug }"
        if node.is_leaf
          a = [ s ]

          todo = node.node_payload
          if todo
            a.push todo.full_source_line
          end
          a * SPACE_
        else
          s
        end
      end
    end

    class Build_pretty_tree_lines_stream___ < Common_::Dyadic

      def initialize t, gs

        @glyphset = gs
        @tree = t

        @glyphset_category_symbol ||= :wide  # wide or narrow
        @line_num_style_a = [ :strong, :yellow ].freeze
        @path_style_a = [ :strong, :green ].freeze
        @tag_style_a = [ :reverse, :yellow ].freeze  # #etc
        @fun = -> do
          fun = Zerk_lib_[]::CLI::Styling
          @fun = -> { fun }
          fun
        end
      end

      def execute
        build_cache
        determine_column_A_width
        via_cache_build_stream
      end

      def build_cache

        y = []

        st = @tree.to_classified_stream_for :text,
          :glyphset_identifier_x, @glyphset_category_symbol

        card = st.gets
        if card.node.children_count.zero?
          card = nil
        end

        while card

          node = card.node

          _line_node_slug = stylize node.slug,
            node.is_branch ? @path_style_a : @line_num_style_a

          s = "#{ card.prefix_string } #{ _line_node_slug }"
          item = Item__.new s, unstyle( s ).length

          y.push item

          todo = node.node_payload
          if todo
            item.todo = todo
          end

          card = st.gets
        end

        @cache_a = y ; nil
      end

      def determine_column_A_width
        @column_A_width = @cache_a.reduce 0 do |m, item|
          m > item.d ? m : item.d
        end ; nil
      end

      def via_cache_build_stream
        d = -1 ; last = @cache_a.length - 1
        Common_::MinimalStream.by do
          if d < last
            line_via_item @cache_a.fetch d += 1
          end
        end
      end

      def line_via_item item
        col_a, col_a_w, todo = item.to_a
        col_b = if todo
          "#{ todo.any_pre_tag_string }#{
           }#{ stylize todo.tag_string, @tag_style_a }#{
            }#{ todo.any_post_tag_string }"
        end
        _space = SPACE_ * ( @column_A_width - col_a_w )
        "#{ col_a }#{ _space } |#{ col_b }"
      end

      def stylize s, a
        @fun[].stylify a, s
      end

      def unstyle s
        @fun[].unstyle s
      end

      Item__ = ::Struct.new :s, :d, :todo
    end

    # -> 2

      end
    end
  end
end
