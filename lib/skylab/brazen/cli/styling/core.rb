module Skylab::Brazen

  class CLI

    module Styling  # :[#092].

      bx = Callback_::Box.new

      define_singleton_method :o do | k, p |
        bx.add k, p
      end

      # ~ styling

      Stylize = -> s, * i_a do
        Stylify[ i_a, s ]
      end

      o :stylize, Stylize

      style_h = nil

      Stylify = -> i_a, s do
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

      # ~ parsing & unparsing

      Parse_styles = -> do

        # produce a structured S-expression from a string with ASCII styles

        rx = /\A
          (?<string>[^\e]+)?  \e\[
          (?<digits> \d+  (?: ; \d+ )* )  m
          (?<rest> .*)
        \z/mx

        sexp = nil

        -> s do

          sexp ||= Home_.lib_.basic::Sexp

          y = []
          begin

            md = rx.match s
            md or break

            s_ = md[ :string ]
            if s_
              y.push sexp[ :string, s_ ]
            end

            _s_a = md[ :digits ].split ';'
            _d_a = _s_a.map( & :to_i )

            y.push sexp[ :style, * _d_a ]

            s = md[ :rest ]
            redo
          end while nil

          if y.length.nonzero?
            if s.length.nonzero?
              y.push sexp[ :string, s ]
            end
            y
          end
        end
      end.call

      o :parse_styles, Parse_styles

      Unstyle_sexp = -> sx do

        # from an S-expression produced by the above function,
        # produce a string representing only the content, with
        # the styling directives removed.

        a = []

        sx.each do | x |
          :string == x.first or next
          a.push x.fetch 1
        end

        a * EMPTY_S_
      end

      o :unstyle_sexp, Unstyle_sexp

      Unparse_style_sexp = -> do

        # from an S-expression produced by function 2 functions above,
        # produce a string that includes the styling represnted therein.

        h = {

          string: -> sexp do
            sexp.fetch 1
          end,

          style: -> sexp do
            "\e[#{ sexp[ 1 .. -1 ] * ';' }m"
          end
        }

        -> sexp do

          a = []

          sexp.each do | x |
            a.push h.fetch( x.first ).call x
          end

          a * EMPTY_S_
        end
      end.call


      # ~ reflection & direct exposure

      -> box do

        h = box.h_

        define_singleton_method :each_pair_at do | * i_a, & p |

          i_a.each do | sym |

            p[ sym, h.fetch( sym ) ]
          end
          NIL_
        end

        h.each_pair do | sym, p |

          define_singleton_method sym, p
        end

      end.call bx
      bx = nil

      # ~ implementation

      bx = Callback_::Box.new
      bx.add :strong, 1
      bx.add :reverse, 7
      a = bx.a_ ; h = bx.h_

      [ :red, :green, :yellow, :blue, :purple, :cyan, :white ].

          each_with_index do | sym, d |

        a.push sym
        h[ sym ] = ( d + 31 )  # ASCII escape sequences, red = 31
      end

      style_h = bx.h_

      Styling_ = self
    end
  end
end
