module Skylab::TanMan

  class StackMagnetics_::ItemStream_via_LineStream < Common_::Actor::Monadic

    def initialize st
      @_is_first = true
      @_anon_d = 0
      @_line_stream = st
    end

    def execute
      @_method = :__main
      Common_.stream do
        send @_method
      end
    end

    def __main
      s = @_line_stream.gets
      if s
        @_line = s
        __via_line
      else
        remove_instance_variable :@_method
        s
      end
    end

    def __via_line
      @_line.chomp!
      md = RX___.match @_line
      if md
        __line_via_matchdata md
      else
        @_sym = __anon
        @_label = @_line
        @_sym_a = nil
        _finish_item
      end
    end

    def __anon
      _d = ( @_anon_d += 1 )
      :"_anonymous_#{ _d }_"
    end

    def __line_via_matchdata md

      @_sym = md[ :sym ].intern
      @_label = md.pre_match

      these = md[ :these ]
      if these
        _s_a = these.split COMMA___
        sym_a = _s_a.map( & :intern )
      end

      @_sym_a = sym_a

      _finish_item
    end

    def _finish_item

      if @_is_first
        @_is_first = false
        is_first = true
      end

      Item___.new @_sym, @_label, is_first, @_sym_a
    end

    RX___ = /[ ]*\((?<sym>[A-Z])\)(?:->\((?<these>[A-Z](?:,[A-Z])*)\))?\z/

    # ==

    class Item___

      def initialize sym, s, is_first, dsym
        @dependency_symbols = dsym
        @is_first = is_first
        @item_label = s
        @item_symbol = sym
      end

      attr_reader(
        :dependency_symbols,
        :is_first,
        :item_label,
        :item_symbol,
      )
    end

    # ==

    COMMA___ = ','
  end
end
