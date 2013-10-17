module Skylab::Headless

  CLI::FUN = MetaHell::FUN::Module.new

  module CLI::FUN

    o = definer

    o[:parse_styles] = -> do
      # Parse a string with ascii styles into an S-expression.

      sexp = Headless::Services::CodeMolester::Sexp

      rx = /\A (?<string>[^\e]+)?  \e\[
        (?<digits> \d+  (?: ; \d+ )* )  m  (?<rest> .*) \z/mx

      -> str do
        res = nil
        loop do
          md = rx.match str
          md or break
          res ||= [ ]
          res << sexp[:string, md[:string]] if md[:string]
          res << sexp[:style, * md[:digits].split( ';' ).map(& :to_i )]
          str = md[:rest]
        end
        if res && str.length.nonzero?
          res << sexp[:string, str]
        end
        res
      end
    end.call

    o[:unparse_styles] = -> do
      h = {
        string: -> sexp { sexp[1] },
        style: -> sexp {  "\e[#{ sexp[1..-1].join ';' }m" }
      }
      -> sexp do
        sexp.reduce [] do |m, sxp|
          m << h.fetch( sxp[0] ).call( sxp )
        end.join ''
      end
    end.call

    o[:unstyle_sexp] = -> sx do
      sx.reduce [] do |m, x|
        m << x[1] if :string == x[0]
        m
      end.join ''
    end

    left_peeker_hack = -> summary_width do     # i'm sorry -- there was no
      max = summary_width - 1                  # other way
      sdone, ldone = {}, {}
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
            left.push '' if l >= max && sopts.length.nonzero?
            left.last << (left.last.length.zero? ? (' ' * 4) : ', ') << s
          end
          x.arg and left.first.concat(
            left[1] ? "#{ x.arg.sub(/\A(\[?)=/, '\1') }," : x.arg )
          left.each { |s| y.call s }
        end
        nil
      end
    end

    # Find the width of the widest content that will go in column A
    # in the help screen of this `option_parser`

    o[:summary_width] = -> option_parser, max = 0 do
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

    Ellipsify___ = -> glyph, limit, string do
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

    Ellipsify__ = Ellipsify___.curry[ '[..]'.freeze ]

    o[ :ellipsify ] = -> str, len do
      Ellipsify__[ len, str ]
    end

    o[:looks_like_sentence] = -> do
      punctuation_character_rx = /[.?!]/
      -> str do
        str.length.nonzero? and str[ -1 ] =~ punctuation_character_rx
      end
    end.call
  end
end
