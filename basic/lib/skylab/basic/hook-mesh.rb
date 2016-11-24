module Skylab::Basic

  class HookMesh

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    # -

      def initialize sym

        @_name_symbol_for_main = sym
        @_hook_box = Common_::Box.new

        yield self

        freeze  # #here
      end

      # -- redefine

      def redefine
        otr = dup  # #here2
        yield otr
        otr.freeze  # #here
      end

      def replace sym, & p
        @_hook_box.replace sym, p
      end

      # -- define

      def main & p
        add @_name_symbol_for_main, & p
        self
      end

      def add sym, & p
        @_hook_box.add sym, p
        self
      end

      # -- read

      def against_value x
        against_value_and_choices x, NOTHING_
      end

      def against_value_and_choices x, cx

        h = @_hook_box.h_

        _invo = Invocation___.new x, cx, h

        h.fetch( @_name_symbol_for_main )[ _invo ]
      end

      # -- internal

      def initialize_copy _  # :#here2
        @_hook_box = @_hook_box.dup
      end

      def freeze  # :#here
        @_hook_box.freeze
        super
      end

    # ==

    class Invocation___

      def initialize x, obs, h
        @__hash = h
        @observer = obs
        @value = x
      end

      def new_with_value x
        dup.__init_with_value( x )
      end

      def __init_with_value x
        @value = x ; self
      end

      def when k
        @__hash.fetch k
      end

      attr_reader(
        :observer,
        :value,
      )

      alias_method :choices, :observer  # your choice  :/
    end
    # ==
  end
end
# #history: born to DRY [ba] string "via mixed" and [tab] statistics.
