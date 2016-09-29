module Skylab::TanMan

  class StackMagnetics_::LineStream_via_Graph < Common_::Actor::Monadic

    def initialize g
      @_graph = g
    end

    def execute
      @_method = :__open
      Common_.stream do
        send @_method
      end
    end

    def __open
      @_method = :__first_body_line
      "digraph g {#{ NEWLINE_ }"
    end

    def __first_body_line

      @_item_stream = @_graph.to_item_stream
      @_method = :__next_item
      send @_method
    end

    def __next_item
      item = @_item_stream.gets
      if item
        __render_item_line item
      else
        remove_instance_variable :@_item_stream
        @_association_stream = @_graph.to_association_stream
        @_method = :__next_association
        send @_method
      end
    end

    def __render_item_line item

      item_sym = item.item_symbol
      s = item.item_label
      # ..
      escaped_item_label = s

      # --

      "  #{ item_sym } [label=\"#{ escaped_item_label }\"]#{ NEWLINE_ }"
    end

    def __next_association
      asso = @_association_stream.gets
      if asso
        "  #{ asso.from_symbol }->#{ asso.to_symbol }#{ NEWLINE_ }"
      else
        @_method = :__done
        "}#{ NEWLINE_ }"
      end
    end

    def __done
      NOTHING_
    end

    NOTHING_ = nil
  end
end
