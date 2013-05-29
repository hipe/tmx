module Skylab::FileMetrics

  module CLI::Lipstick

    # lipstick is the rendering with glyphs of a certain normalized scalar
    # (a "ratio" between 0.0 and 1.0 incl.), taking into account how
    # wide the screen is at render time.

    FIELD = {
      header: '',
      is_autonomous: true,
      cook: -> metrics do
        CLI::Lipstick.initscr  # here is as good as anywhere. - comment out!
        CLI::Lipstick[ metrics, -> { 80 } ]  # screen width fallback !
      end
    }

    set_cols = get_cols = nil

    -> do  # `[]`

      min_room = 4
      margin = 1
      norm = stylus = stylize = nil

      define_singleton_method :[] do |metrics, fallback|
        pane_width = get_cols[] || fallback[]
        sep = metrics.sep
        before = metrics.max_a.reduce( :+ ) +
          ( [ metrics.max_a.length - 1, 0 ].max * sep.length )
          # (minus one because it's a separator, minus one b.c we don't
          # count lipstick, and then plus one for the left margin hack
          # (which happens at exactly [#008]))

        my_room = -> do
          x = ( before + sep.length ) * -1 + pane_width - margin
          [ x, min_room ].max
        end.call
        -> pxy do
          if pxy  # allow nil to mean "don't do it"
            stylize[ "+" * ( norm[ pxy.normalized_scalar ] * my_room ).to_i ]
          end
        end
      end

      norm = -> x do
        [ [ x, 0.0 ].max, 1.0 ].min
      end

      stylus = nil
      stylize = -> s do
        ( stylus ||= Headless::CLI::Pen::MINIMAL ).stylize s, :green
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
