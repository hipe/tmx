module Skylab::TanMan

  class StackMagnetics_::LineStream_via_Graph < Common_::Monadic

    WORD_WRAP_ASPECT_RATIO___ = [ 5, 1 ]

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

      s_a = s.split SPACE_

      # --

      buffer = nil
      p = -> line do
        buffer = Sanitize__[ line ]
        p = -> line_ do
          buffer.concat "\\n#{ Sanitize__[ line_ ] }"
        end
      end
      _y = ::Enumerator::Yielder.new do |line|
        p[ line ]
      end

      Home_.lib_.basic::String::WordWrapper::Calm.with(
        :aspect_ratio, WORD_WRAP_ASPECT_RATIO___,
        :downstream_yielder, _y,
        :input_words, s_a,
      )

      a = nil
      if item.is_first
        ( a ||= [] ).push [ 'style', 'filled' ]
        a.push ['fillcolor', '"#b5d5fb"']  # light blue
      end

      if a
        _st = Common_::Stream.via_nonsparse_array( a ).map_by do |pair|
          ", #{ pair.first}=#{ pair.last }"  # meh
        end
        _ = _st.join_into ""
      end

      # --

      "  #{ item_sym } [label=\"#{ buffer }\"#{ _ }]#{ NEWLINE_ }"
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

    Sanitize__ = -> line do
      line.gsub! BACKSLASH_, EMPTY_S_   # meh
      line.gsub! DOUBLE_QUOTE_, ESCAPED_QUOTE_
      line
    end

    BACKSLASH_ = '\\'
    ESCAPED_QUOTE_ = '\\"'
    DOUBLE_QUOTE_ = '"'
  end
end
