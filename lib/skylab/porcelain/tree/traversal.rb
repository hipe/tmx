module ::Skylab::Porcelain

  class Tree::Traversal

    # Tree::Fields_[ self, :crook, :pipe, :tee ]

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
      def fetch i
        instance_variable_get IVAR_H_.fetch( i )
      end
    end

  protected

    def normalize_glyphset
      if @glyphset_x.respond_to? :id2name
        @glyphset_x = Headless::CLI::Tree::Glyph::Sets.
          const_fetch @glyphset_x
      end
      safe_name_p = get_safe_name_p
      @glyphset_x.each do |i, x|
        safe_name_p[ i ] or raise ::NameError, "bad glyph name - #{ i }"
        instance_variable_set :"@#{ i }", x
      end
      nil
    end

    -> do
      p = nil
      define_method :get_safe_name_p do
        p ||= ::Hash[ Headless::CLI::Tree::Glyphs.each.map do |g|
          [ g.normalized_glyph_name, true ]
        end ].freeze
      end
      private :get_safe_name_p
    end.call

    def work node, card
      @each[ card ]
      sum = 1
      if node.has_children
        push card
        last = node.children_count - 1
        node.children.each_with_index do |child, idx|
          sum += work child,
            MutableCard_.new( child, @level, idx.nil?, last==idx )
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
      if card.level  # no card on root node
        "#{ @prefix_stack_a * '' }#{ card.is_last ? crook : tee }"
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

    Headless::CLI::Tree::Glyphs.each do |g|
      attr_reader g.normalized_glyph_name  # blank crook pipe separator tee
    end
  end
end
