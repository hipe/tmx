module Skylab::DocTest

  class Models_::Before_Node
    # -
      # -
        class << self

          alias_method :build, :new
        end

        def initialize first_content_line, line_s_a
          @a = line_s_a
          @each_or_all = if BEFORE_ALL_HACK_RX__ =~ first_content_line
            :all
          else
            :each
          end
        end

        BEFORE_ALL_HACK_RX__ = /\A[[:space:]]*(?:class |module |[A-Z])/

        def members
          [ :before_block_category_symbol, :to_line_stream, :node_symbol ]
        end

        def node_symbol_when_context
          node_symbol
        end

        def node_symbol
          :before_node
        end

        def before_block_category_symbol
          @each_or_all
        end

        def to_line_stream
          Common_::Stream.via_nonsparse_array @a
        end
      # -
    # -
  end
end
