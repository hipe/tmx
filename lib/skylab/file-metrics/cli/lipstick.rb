module Skylab::FileMetrics

  module CLI::Lipstick

    # lipstick is the rendering with glyphs of a certain normalized scalar
    # (a "ratio" between 0.0 and 1.0 incl.)

    set_cols = get_cols = nil

    -> do  # `[]`

      min_room = 4
      margin = 1
      norm = stylus = stylize = nil

      define_singleton_method :[] do |row_a, sep, fallback|
        pane_width = get_cols[] || fallback[]
        before = row_a.join( sep ).length
        my_room = -> do
          x = ( before + sep.length ) * -1 + pane_width - margin
          [ x, min_room ].max
        end.call
        lipstick = -> ratio do
          if ratio  # allow nil to mean "don't do it"
            stylize[ "+" * ( norm[ ratio ] * my_room ).to_i ]
          end
        end
        -> ratio, rw_a, _ do
          rw_a << lipstick[ ratio ]
        end
      end

      norm = -> x do
        [ [x, 0.0].max, 1.0 ].min
      end

      stylus = nil
      stylize = -> s do
        stylus ||= Headless::CLI::Pen::MINIMAL
        stylus.stylize s, :green
      end
    end.call

    define_singleton_method :initscr do
      begin
        v = $VERBOSE; $VERBOSE = nil
        Services::Ncurses.initscr
        $VERBOSE = v # snowleopard-ncurses ncurses_wrap.c:1951 @todo easy patch
        set_cols[ ::Ncurses.COLS ]
        ::Ncurses.endwin
      rescue ::LoadError
      end
    end

    set_cols, get_cols = -> do
      num = nil
      set = -> x do
        num = x
      end
      get = -> do
        num
      end
      [ set, get ]
    end.call
  end
end
