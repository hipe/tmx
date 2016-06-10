module Skylab::DocTest

  class Models_::Context
    # -
      # -
        class << self

          alias_method :build, :new

        end

        def initialize text_span, mutable_a
          @description_s = Models_::Description_String[ text_span.a.last ]
          @node_a = mutable_a
        end

        def members
          [ :description_string, :to_child_stream, :node_symbol ]
        end

        def node_symbol
          :context_node
        end

        def description_string
          @description_s
        end

        def to_child_stream
          Common_::Stream.via_nonsparse_array @node_a
        end
      # -
    # -
  end
end
