module Skylab::FileMetrics
  module CLI::Lipstick
    MIN_ROOM = 4
    MARGIN = 1
    def self.build rows, separator, fallback
      sane = ->(x) { [[x, 0.0].max, 1.0].min }
      pane_width = COLS.call || fallback[:pane_width].call
      before = rows.join(separator).length
      my_room = [ (before + separator.length)*-1 + pane_width - MARGIN, MIN_ROOM ].max
      stylus = ::Skylab::Porcelain::TiteColor
      stylize = ->(s) { stylus.stylize(s, :green) }
      lipstick = ->(ratio) { stylize['+' * (sane[ratio] * my_room).to_i] }
      ->(ratio, rowz, _) { rowz.push lipstick.call(ratio) }
    end

    _cols = nil
    COLS = ->(cols = nil) { cols ? (_cols = cols) : _cols }

    def self.initscr
      require 'ncurses'
      _d = $VERBOSE; $VERBOSE = nil
      ::Ncurses.initscr
      $VERBOSE = _d # snowleopard-ncurses ncurses_wrap.c:1951 @todo easy patch
      COLS.call ::Ncurses.COLS
      ::Ncurses.endwin
    rescue ::LoadError
    end
  end
end
