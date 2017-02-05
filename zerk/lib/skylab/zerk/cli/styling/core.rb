module Skylab::Zerk

  module CLI::Styling  # :[#023.1].

    class << self
      def o m, p
        define_singleton_method m, p
      end
    end  # >>

    # -

      # ~ styling

      Stylize = -> s, * i_a do

        # (this method-form looks better when called inline)

        Stylify[ i_a, s ]
      end

      o :stylize, Stylize

      style_h = nil

      Stylify = -> i_a, s do

        # (this method-form is more #curry-friendly, better for `define_method`)

        "\e[#{ i_a.map { |i| style_h.fetch i }.compact * ';' }m#{ s }\e[0m"
      end

      o :stylify, Stylify

      # ~ un-styling

      Unstyle = -> s do
        Unstyle_styled[ s ] || s
      end

      o :unstyle, Unstyle

      Unstyle_styled = -> s do
        s.dup.gsub! SIMPLE_STYLE_RX, EMPTY_S_
      end

      SIMPLE_STYLE_RX = /\e  \[  \d+  (?: ; \d+ )*  m  /x

      o :unstyle_styled, Unstyle_styled

      # ~ refl

      class << self

        def code_name_symbol_array  # [css], uncovered
          COLORS___
        end
      end  # >>

      # ~ implementation

      bx = Common_::Box.new
      bx.add :strong, 1
      bx.add :reverse, 7
      a = bx.a_ ; fwd_h = bx.h_

      colors = [ :red, :green, :yellow, :blue, :purple, :cyan, :white ]
      colors.each_with_index do |sym, d|
        a.push sym
        fwd_h[ sym ] = ( d + 31 )  # ASCII escape sequences, red = 31
      end

      style_h = bx.h_

      Reverse_hash_ = Lazy_.call do  # 1x
        h = style_h.invert
        h[ 0 ] = :no_style  # <- we never say this explicitly when encoding
        h.freeze
      end

      COLORS___ = colors

    # -
    # ==

    INTEGER_VIA_SYMBOL_HASH = style_h  # 1x [ba]

    # ==
  end
end
# #history: moved from [br] to [ze]
