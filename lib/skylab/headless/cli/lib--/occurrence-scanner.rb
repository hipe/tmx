module Skylab::Headless

  class CLI::Lib__::Occurrence_scanner < Scn_

    Occurrence__ = ::Struct.new :before, :match, :lineno, :colno, :byte

    define_singleton_method :[], -> rx, fh do
      p = lineno = colno = byte = rx_ = scn = nil
      done = -> do
        p = -> { } ; nil
      end
      advance = -> line do
        scn.string = line
        lineno += 1 ; colno = 1 ; nil
      end
      scan = -> do
        befor = scn.scan rx_
        match = scn.scan rx
        d = ( befor ? befor.length : 0 ) + ( match ? match.length : 0 )
        d.zero? and fail "scanning logic error - #{ scn.string.inspect }"
        r = Occurrence__[ befor, match, lineno, colno, byte ]
        byte += d ; colno += d
        if scn.eos?
          line = fh.gets
          if line then advance[ line ] else done[] end
        end
        r
      end
      p = -> do
        fh.pos.zero? or raise ::ArgumentError, "file must be at pos 0"
        rx_ = /(?:(?!#{ rx.source }).)+\r?\n?|\r?\n/
        line = fh.gets
        line && line.length.nonzero? or break done[]
        lineno = colno = 1 ; byte = 0
        scn = Home_::Library_::StringScanner.new line
        (( p = scan ))[]
      end
      super -> { p[] }
    end

    ZERO_LENGTH_LINE_RX__ = /\A\r?(?:\n|\z)/
  end
end
