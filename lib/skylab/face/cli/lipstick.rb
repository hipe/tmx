module Skylab::Face

  class CLI::Lipstick < ::Module

    # a "lipstick" is an abstract rendering entity whose job it is to render
    # with glyphs (e.g "+" (pluses)) a certain normalized scalar (a "ratio"
    # between 0.0 and 1.0 inclusive), taking into account how wide the screen
    # is at some particular time.
    #
    # its inspiration is the green and red pluses and minuses that appear in a
    # typical `git show --stat`.
    #
    # although it has gone through three overahauls, the interface is still
    # obtuse for reasons.

    def initialize *a
      @a = a
      nil
    end

    def instance
      if const_defined? :Instance_, false
        const_get :Instance_, false
      else
        const_set :Instance_, self::Class_.new( * @a )
      end
    end

    -> do  # `self.cols`

      first = true ; cols = nil
      define_singleton_method :cols do
        if first
          first = false
          # (we used to rescue ::LoadError, could again)
          MetaHell::FUN.without_warning[ -> do
            Services::Ncurses.initscr
            # snowleopard-ncurses ncurses_wrap.c:1951 @todo easy patch
          end ]
          cols = ::Ncurses.COLS
          ::Ncurses.endwin
        end
        cols
      end
    end.call
  end

  CLI::Lipstick::Class_ = MetaHell::Function::Class.new :cook
  class CLI::Lipstick::Class_

    def initialize *args  # [glyph-string] [color-symbol] [default-cols-func]

      @glyph, @color, @default_width = MetaHell::FUN.parse_series[ args,
        -> x { x.respond_to? :ascii_only? },
        -> x { x.respond_to? :id2name },
        -> x { x.respond_to? :call } ]

      @glyph ||= '.' ; @default_width ||= -> { 72 }  # meh
      min_room = 4 ; margin = 1

      norm = -> x do
        [ [ x, 0.0 ].max, 1.0 ].min
      end

      @cook = -> a, seplen=0 do
        pane_width = CLI::Lipstick.cols || @default_width[]
        befor = a.reduce( :+ ) + ( [ a.length - 1, 0 ].max * seplen )
          # minus one because it's a separator, minus one b.c we don't count
          # lipstick, and then plus one for the left margin hack [#fm-008]
        my_room = -> do
          x = ( befor + seplen ) * -1 + pane_width - margin
          [ x, min_room ].max
        end.call

        stylize = -> do
          if ! @color then -> s { s } else
            stylus = Services::Headless::CLI::Pen::MINIMAL
            clr = @color
            -> s { stylus.stylize s, clr }
          end
        end.call

        -> scalar_pxy do
          if scalar_pxy  # allow nil to mean "don't do it"
            stylize[ @glyph *
                ( norm[ scalar_pxy.normalized_scalar ] * my_room ).to_i ]
          end
        end
      end
    end
  end
end
