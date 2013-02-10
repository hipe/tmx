module Skylab::Headless

  module CLI

    o = { }

    o[:parse_styles] = -> do
      # Parse a string with ascii styles into an S-expression.

      sexp = Headless::Services::CodeMolester::Sexp

      rx = /\A (?<string>[^\e]+)?  \e\[
        (?<digits> \d+  (?: ; \d+ )* )  m  (?<rest> .*) \z/x

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

    left_peeker_hack = -> summary_width do     # i'm sorry -- there was no
      max = summary_width - 1                  # other way
      sdone, ldone = {}, {}
      -> x, &y do
        sopts, lopts = [], []   # short and long opts that have not been done
        x.short.each { |s| sdone.fetch(s) { sopts.push s ; sdone[s] = true } }
        x.long.each  { |s| ldone.fetch(s) { lopts.push s ; ldone[s] = true } }
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

      option_parser.top.list.reduce max do |m, x|
        if x.respond_to? :summarize
          left_peek.call( x ) do |str|
            str.length > m and m = str.length
          end
        end
        m
      end
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } # note -
    # because of something awful that autoloader does we do not freeze ourself
  end
end
