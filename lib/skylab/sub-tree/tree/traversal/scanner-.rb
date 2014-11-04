module Skylab::SubTree

  class Tree::Traversal

    class Scanner_

      SubTree_::Lib_::Funcy_globful[ self ]

      SubTree_::Lib_::Basic_fields[ :client, self,
        :absorber, :absrb_iambic_fully,
        :field_i_a, [ :glyphset_x ]]

      class Scn__ < ::Proc
        alias_method :gets, :call
      end
      class Scn_ < Scn__
        def initialize
          @count = 0
          super
        end
        alias_method :gets, :call
        def gets
          @count += 1
          super
        end
        attr_reader :count
      end

      def initialize tree, * x_a
        @tree = tree
        @initial_spaces ||= '  '
        absrb_iambic_fully x_a ; nil
      end

      def execute
        @glyphset_x ||= :narrow  # DEFAULT_GLYPHSET_
        Normalize_and_absorb_glyphset_x[ self ]
        @gets = -> do
          first
        end
        Scn_.new do
          @gets.call
        end
      end

    private

      def first
        card = MutableCard_.new( @tree, 0 )
        card.prefix = -> { @initial_spaces }
        if @tree.has_children
          @longevity_a = [ true ]
          @stack_a = [ Frame_.new( @tree, card ) ]
          @gets = -> { work }
        else
          @gets = DONE_
        end
        card
      end

      DONE_ = EMPTY_ = EMPTY_P_

      def push node, card
        node.has_children or fail "sanity"
        @stack_a.push Frame_.new( node, card )
        @longevity_a[ card.level ] = card.is_last
        nil
      end

      def work
        child, is_first, is_last = @stack_a.last.advance
        card = MutableCard_.new( child, @stack_a.length, is_first, is_last )
        card.prefix = -> { render_prefix card }
        if child.has_children
          push child, card
        elsif is_last
          @stack_a.pop
          while @stack_a.length.nonzero? and @stack_a.last.is_exhausted
            @stack_a.pop
          end
          if @stack_a.length.zero?
            @gets = DONE_
          end
        end
        card
      end

      def render_prefix card
        a = card.level.times.map do |x|
          @longevity_a[ x ] ? @blank : @pipe
        end
        tail = card.is_last ? @crook : @tee
        "#{ a * EMPTY_S_ }#{ tail }"
      end
    end

    class Scanner_::Frame_

      def initialize node, card  # assume children
        @node = node
        @last = node.children_count - 1
        @current = 0

      end

      def advance
        child = @node.fetch_child_at_index @current
        is_first = @current.zero?
        if @last == @current
          @node = @current = nil
          is_last = true
        else
          @current += 1
        end
        [ child, is_first, is_last ]
      end

      def is_exhausted
        @current.nil?
      end
    end
  end
end
