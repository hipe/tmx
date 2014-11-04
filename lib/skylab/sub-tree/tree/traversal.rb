module Skylab::SubTree

  class Tree::Traversal

    # Tree::Entity_[ self, :properties, :crook, :pipe, :tee ]

    def initialize
      @glyphset_x = nil
    end

    def traverse root, &b
      @level = 0 ; @each = b ; ( @prefix_stack_a ||= [] ).clear
      @glyphset_x ||= DEFAULT_GLYPHSET_
      normalize_glyphset
      work root, MutableCard_.new( root )
    end

    DEFAULT_GLYPHSET_ = :narrow  # e.g :narrow | :wide

    class MutableCard_
      FIELD_A_ = [ :node, :level, :is_first, :is_last ].freeze
      IVAR_H_ = ::Hash[ FIELD_A_.map { |i| [ i, :"@#{ i }" ] } ]
      def initialize node, level=nil, is_first=nil, is_last=nil
        @node = node ; @level = level
        @is_first = is_first ; @is_last = is_last
      end
      attr_reader( * FIELD_A_ )
      attr_accessor :prefix
      def keys
        FIELD_A_
      end
      alias_method :members, :keys
      def fetch i
        instance_variable_get IVAR_H_.fetch( i )
      end
    end

  private

    def normalize_glyphset
      Normalize_and_absorb_glyphset_x[ self ]
    end

    Normalize_and_absorb_glyphset_x = -> client do
      client.instance_exec do
        gs = @glyphset_x
        x = Resolve_glyphset_[ gs ] and @glyphset_x = gs = x
        Absorb_glyphs_into_ivars_[ self, gs ]
      end
    end

    Resolve_glyphset_ = -> x do
      if x.respond_to? :id2name
        Autoloader_.const_reduce [ x ], SubTree_::Lib_::CLI_lib[].tree.glyph_sets_module
      end
    end

    Absorb_glyphs_into_ivars_ = -> client, gs do
      client.instance_exec do
        safe_name_p = Get_safe_glyph_p_[]
        gs.each do |i, x|
          safe_name_p[ i ] or raise ::NameError, "bad glyph name - #{ i }"
          instance_variable_set :"@#{ i }", x
        end
      end
      nil
    end

    Get_safe_glyph_p_ = -> do
      p = -> do
        _a = SubTree_::Lib_::CLI_lib[].tree.glyphs.each_const_value.map do |g|
          [ g.normalized_glyph_name, true ]
        end
        p = ::Hash[ _a ].freeze
      end
    end.call

    def work node, card
      @each[ card ]
      sum = 1
      if node.has_children
        push card
        last = node.children_count - 1
        node.children.each_with_index do |child, idx|
          sum += work child,
            MutableCard_.new( child, @level, idx.zero?, last==idx )
        end
        pop
      end
      sum
    end

    def push card
      @level += 1
      @prefix_stack_a.push parent_prefix( card )
      nil
    end

    def pop
      @level -= 1
      @prefix_stack_a.pop
      nil
    end

  public

    #  ~ `service` methods called from the outside for rendering ~

    def prefix card
      if card.level  # no prefix on root node
        "#{ @prefix_stack_a * EMPTY_S_ }#{ card.is_last ? crook : tee }"
      end
    end

    def render_node node
      node.slug if node.has_slug
    end

    def parent_prefix card
      if card.level
        card.is_last ? blank : pipe
      end
    end

    SubTree_::Lib_::CLI_lib[].tree.glyphs.each_const_value do |glyph|
      attr_reader glyph.normalized_glyph_name  # blank crook pipe separator tee
    end
  end
end
