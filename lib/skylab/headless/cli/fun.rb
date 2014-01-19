module Skylab::Headless

  CLI::FUN = MetaHell::FUN::Module.new

  module CLI::FUN

    Parse_styles = -> do
      # Parse a string with ascii styles into an S-expression.

      sexp = Headless::Library_::CodeMolester::Sexp

      rx = /\A (?<string>[^\e]+)?  \e\[
        (?<digits> \d+  (?: ; \d+ )* )  m  (?<rest> .*) \z/mx

      -> s do
        y = [] ; begin
          md = rx.match( s ) or break
          md[ :string ] and y << sexp[ :string, md[ :string ] ]
          y << sexp[ :style, * md[ :digits ].split( ';' ).map( & :to_i ) ]
          s = md[ :rest ]
        end while true
        if y.length.nonzero?
          s.length.nonzero? and y << sexp[ :string, s ]
          y
        end
      end
    end.call

    Unparse_styles = -> do
      h = {
        string: -> sexp { sexp[1] },
        style: -> sexp {  "\e[#{ sexp[1..-1].join ';' }m" }
      }
      -> sexp do
        sexp.reduce [] do |m, sxp|
          m << h.fetch( sxp.first ).call( sxp )
        end.join EMPTY_STRING_
      end
    end.call

    Unstyle_sexp = -> sx do
      sx.reduce [] do |m, x|
        :string == x.first and m << x[ 1 ] ; m
      end.join EMPTY_STRING_
    end

    left_peeker_hack = -> summary_width do     # i'm sorry -- there was no
      max = summary_width - 1                  # other way
      sdone = {} ; ldone = {}
      -> x, &y do
        sopts, lopts = [], []   # short and long opts that have not been done
        if x.short
          x.short.each { |s| sdone.fetch(s) { sopts.push s ; sdone[s] = true } }
        end
        if x.long
          x.long.each  { |s| ldone.fetch(s) { lopts.push s ; ldone[s] = true } }
        end
        if sopts.length.nonzero? || lopts.length.nonzero?
          left = [sopts.join(', ')]
          lopts.each do |s|
            l = left.last.length + s.length
            l += x.arg.length if 1 == left.length && x.arg
            l >= max and sopts.length.nonzeor? and
              left << EMPTY_STRING_
            _sep = left.last.length.zero? ? ( TERM_SEPARATOR_STRING_ * 4 ) :
              ', '
            left.last << _sep << s
          end
          x.arg and left.first.concat(
            left[1] ? "#{ x.arg.sub(/\A(\[?)=/, '\1') }," : x.arg )
          left.each { |s| y.call s }
        end
        nil
      end
    end

    Summary_width = -> option_parser, max=0 do  # find the width of the widest
      # content that will go in column A in the help screen of this o.p
      left_peek = left_peeker_hack[ option_parser.summary_width ]
      CLI::Option::Enumerator.new( option_parser ).reduce max do |m, x|
        if x.respond_to? :summarize
          left_peek.call( x ) do |str|
            str.length > m and m = str.length
          end
        end
        m
      end
    end

    # ( the below curry chain exemplifies [#101] name conventioons for.. )

    Ellipsify__ = -> glyph, limit, string do
      if string.length <= limit
        string
      elsif glyph.length <= limit
        "#{ string[ 0, ( limit - glyph.length ) ] }#{ glyph }"
      else
        case limit  # this is what you get. [#it-001] is much more ambitious
        when 0 ;  # and much less existant.
        when 1 ; '.'
        when 2 ; '[]'
        when 3 ; '[.]'
        else glyph[ 0, limit ]
        end
      end
    end

    Ellipsify_ = Ellipsify__.curry[ '[..]'.freeze ]

    Ellipsify = Ellipsify_.curry[
      Headless::Library_::Basic::FUN::A_REASONABLY_SHORT_LENGTH_FOR_A_STRING ]

    Looks_like_sentence = -> do
      punctuation_character_rx = /[.?!]/
      -> str do
        str.length.nonzero? and str[ -1 ] =~ punctuation_character_rx
      end
    end.call

    Cols = -> do
      cols_p = -> else_p do
        begin require 'ncurses' ; rescue ::LoadError => e ; end
        if e then else_p[] else
          v = $VERBOSE ; $VERBOSE = nil
          ::Ncurses.initscr
          # #todo easy patch snowleopard-ncurses ncurses_wrap.c:1951
          $VERBOSE = v
          cols = ::Ncurses.COLS
          ::Ncurses.endwin
          cols_p = -> { cols } ; cols
        end
      end
      -> else_p { cols_p[ else_p ] }
    end.call
  end
end
