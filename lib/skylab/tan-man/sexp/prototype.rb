# [#bs-010] poster child (used to be!)

module Skylab::TanMan
  module Sexp::Prototype

    # Check out this wondrously obtuse, undoubtedly insane but gloriously
    # useful hack: if you use the keyword `example` (without the quotes) in
    # either a { c-style or shell-style }-looking comment in the document you
    # are parsing, and it is of the form
    #
    #   'example' [name_token [..]] rule_name { ':' | eol }
    #
    # and what follows is a valid parsable string using <rule_name>
    # from your grammar, then this example will get parsed and turned
    # into a "prototype" than can be used elsewhere by other hacks
    # lurking in this library!! SO FACEPALMING!!!!!!!!11111


    o = { }

    o[:keyword] = 'example'

    o[:blank_rx] = /\A[[:space:]]*\z/

    o[:line_rx] = / [^\r\n]* \r? \n  |  [^\r\n]+ \r? \n? /x

    o[:rex] = ->( str ) { ::Regexp.escape str }

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end



  class << Sexp::Prototype

    keyword = Sexp::Prototype::FUN.keyword

    define_method :match  do |prev_tree, curr_tree, tree_class, member|
      res = nil
      begin
        ::String === prev_tree or break        # of each string
        prev_tree.include? keyword or break    # if it contains this string
        scn = ::StringScanner.new prev_tree    # then skip over any leading
        scn.skip( /[\r\n]+/ )                  # newlines,
        klass = line_header = nil
        begin
          shell_style_comment_header = scn.scan( /[ \t]*#[ \t]*/ )
          if shell_style_comment_header                     # make a note of
            klass = Sexp::Prototype::ShellStyle             # what kind of
            line_header = shell_style_comment_header        # comment it is
            break                                           # and the line-
          end
          found_c_style_opener = scn.skip %r{ [ \t]* / \* }x
          if found_c_style_opener                           # header, if any
            klass = Sexp::Prototype::C_Style                # (for this string
            scn.skip( /([ \t]*[\r\n]+)+/ )                  # may not be a
            line_header = scn.scan( /[ \t]*/ )              # comment at all).
          end
        end while nil
        klass || line_header or break          # maybe it wasn't a comment.
        klass && line_header or fail 'sanity'  # (we care about sanity a lot)

        res = klass.new scn, curr_tree,        # now we pass off into the future
          line_header, member, tree_class      # an executable hack object
                                               # that may or may not be valid
      end while nil                            # with the sanner advanced to
      res                                      # the position it is advanced to.
    end                                        # (the cutoff point for process-
  end                                          # ing it here is sort arbitrary.)



  class Sexp::Prototype::Hack < ::Struct.new :scn, :curr_tree, :line_header,
                                               :member, :tree_class

    def commit!
      res = nil                                # all you know at this point is
      keyword_found = skip_until_keyword!      # that you are a comment-looking
      while keyword_found                      # thing with substring 'example'
        attempt_to_process_example!            # (result is nil or true but..)
        keyword_found = skip_until_keyword!    # so batch-style, one-by-one
      end                                      # for each keyword you see try
                                               # to get an example out of it.
      res = active_hub                         # this is either a new empty
      res                                      # list tree we made or maybe
    end                                        # something else..

  protected

    attr_accessor :active_hub                  # for now the 'hub' is the
                                               # enhanced sexp (either existing
                                               # in the doc or created here)
                                               # that winds up holding the
                                               # prototypes!
    name_rx = /[_a-z][_a-z0-9]*/i

    define_method :attempt_to_process_example! do # you have been advanced to
      res = nil                                # after the keyword and any
      begin                                    # following simple whitespace.
        name_tokens = []                       # populate `name_tokens`
        loop do                                # with each successive simple
          name = scn.scan( name_rx ) or break  # "name token" we find separated
          name_tokens.push name                # by simple whitespace.  We want
          scn.skip( /[ \t]+/ )                 # there to be one or more such
        end                                    # tokens after the keyword else
        name_tokens.empty? and break           # it is not a match.
        # 'example' [ name_token [..]] rule_name { ':' | eol }

        if ! grammar.has_rule? name_tokens.last
          debug? and info "#{ grammar.grammar_const } grammar has no #{
            }#{ name_tokens.last.inspect } rule" # given how far we've come, it
          break                                # might be useful to get feedback
        end

        @name_tokens = name_tokens             # meh
        res = attempt_to_process_example_body!

      end while nil
      res
    end

    fun = Sexp::Prototype::FUN
    blank_rx = fun.blank_rx
    line_rx = fun.line_rx

    define_method :attempt_to_process_example_body! do
      result = nil
      new_parser = -> do
        parser = grammar.build_parser_for_rule @name_tokens.last
        parser.consume_all_input = false       # hack to allow trailing newlines
        parser                                 # that might exist cosmetically
      end
      begin
        body = attempt_to_scan_example_body!   # (if no body came of this it
        body or break                          # emitted a debugging message)
        parser = new_parser[ ]                 # We make a parser for the
        res = parser.parse body                # appropriate rule and try to
        if ! res and /\A[ \t]+/ =~ body        # parse the example body as is.
          b = $~.post_match                    #   (Hackisly, if that failed,
          p = new_parser[ ]                    #   we try again but this time
          r = p.parse b                        #   without the leading
          if r                                 #   whitespace omg it's so bad
            res = r ; parser = p               #   but so good!)
          end
        end
        reason = nil
        begin # set reason
          if ! res
            reason = parser.failure_reason
            break
          end
          if parser.input.length > parser.index
            tail = parser.input[ parser.index .. -1 ]
            if /[^[:space:]]/ =~ tail
              res = nil # important
              reason = "could not parse: #{ tail.inspect }"
            end
          end
        end while nil
        if ! res
          # we raise to stay on spec but this could (should?) change to an info
          raise "when parsing your \"#{ @name_tokens.join ' ' }\" prototype #{
            }embedded in a comment: #{ reason }"
          break
        end
        result = process_parse_result res      # probably true or false
      end while nil
      result
    end


    define_method :attempt_to_scan_example_body! do
      body = nil                               # please watch carefully b/c this
      begin                                    # logic is deceivingly tricky:
        if scn.skip( /[ \t]*:/ )               # if there is a colon and it
          if scn.match?( /[ \t]*[^ \t\n\r]/ )  # looks like it has "content"
            scn.skip( /[ \t]/ )                # after it, skip (ick) only 1 sp
            body = scn.scan( /[^\n\r]+/ ) or sanity # and let body be the rest
            break                              # of the line.
          end                                  # now, since the above wasn't a
        end                                    # single-line thing, chomp any
        scn.skip( / [ \t]* \r? \n? /x )        # trailing simple spaces and at
        body = attempt_to_scan_multiline_example_body! # most one line ending
      end while nil                            # and try to process it as a
      body                                     # multi-line thing.
    end

    def debug?
      TanMan::Sexp::Auto.debug?
    end

    def info msg
      TanMan::Sexp::Auto.debug_stream.puts msg
    end

    def grammar
      tree_class.grammar
    end

    def process_parse_result syntax_node
      sexp = tree_class.element2tree syntax_node, :whatever
      res = nil

      use_name = -> do                         # for now, we use either the
        str = nil                              # last name (which is a rule
        case @name_tokens.length               # name, or the penultimate
        when 1 ; str = @name_tokens[0]         # name alone, and have not
        when 2 ; str = @name_tokens[0]         # defined how to handle long
        else
          info "sorry - we have not yet designed support for multi-#{
            }word names yet - \"#{ @name_tokens.join ' ' }\""
          res = false
        end
        str.intern if str
      end.call

      begin
        use_name or break
        if active_hub
          active_hub.set_named_prototype! use_name, sexp
        else
          hub = nil
          if curr_tree
            curr_tree.class == sexp.class or fail 'test me'
            curr_tree._prototype and fail 'sanity - _prototype already set!'
            hub = curr_tree
          elsif sexp.list?
            hub = sexp.class.new
          else
            fail "implement me - prototypes for non-list rules"
          end
          hub._prototype = sexp
          hub.extend Sexp::Prototype::Hub_InstanceMethods
          self.active_hub = hub
        end
        res = true
      end while nil
      res
    end


    keyword = fun.keyword
    rex = fun.rex

    define_method :skip_until_keyword! do

      @keyword_rx ||= %r{                      # match only those keywords
        (?: \A  |  ^ #{ rex[ line_header ] } ) # that come after either
        [ \t]* #{ rex[ keyword ] } [ \t] +     # begin. of string or (beg of
                                               # line after lineheader)
      }x

      res = scn.skip_until @keyword_rx
      res
    end
  end



  class Sexp::Prototype::ShellStyle < Sexp::Prototype::Hack

    # no public methods defined here.

  protected

    fun = Sexp::Prototype::FUN
    blank_rx = fun.blank_rx
    line_rx = fun.line_rx

    define_method :attempt_to_scan_multiline_example_body! do
      lines = [ ]                              # we are at the beginning of our
      begin                                    # first line of multiline fun.
        line = scn.scan line_rx                # with each next line that you
        while line                             # can scan, if ever you get a
          if blank_rx =~ line                  # truly blank line (no ln hdr)
            break                              # then it is the end of the
          end                                  # comment block and we are done.
          line = deindent line                 # remove line_header (like ' # ')
          if blank_rx =~ line && ! lines.empty?# for cosmetics
            break                              # we allow any first blank line
          end                                  # otherwise, the first blank
          lines.push line                      # (after deindenting) indicates
          line = scn.scan line_rx              # the end of the example body.
        end
      end while nil
      body = nil
      if lines.empty?
        debug? and info "strange -- multiline comment body expected for #{
          }\"#{ @name_tokens.join ' ' }\""
      else
        body = lines.join ''
      end
      body
    end

    rex = fun.rex

    define_method :deindent do |line|          # remove e.g. " #" from lines

      @deindent ||= -> do                      # only once make a de-indenter
        start = line_header.length             # that simply removes the num.
        -> ln  { ln[ start .. -1 ] }           # of chars corresponding to the
      end.call                                 # width of the line header

      res = nil                                # so, for a string like " # foo"
      begin                                    # and a line header of " # "
        idx = line.index line_header           # the result is "foo"
        if 0 == idx                            # (line header was set way back
          res = @deindent[ line ]              # at the beginning)
          break
        end
        @blank_commented_line_rx ||= -> do     # (i don't believe it -- this
          md = /\A.*[^[:blank:]](?=[[:blank:]]*\z)/.match line_header # could
          rx = /\A#{ rex[ md[0] ] }(?<newline>\r?\n?)\z/ # probably all be done
          rx                                   # in like one line but here
        end.call                               # this is: for a string like
        match = @blank_commented_line_rx.match line # "#\n" we have to result
        if match                               # in "\n"
          res = match[:newline]
          break
        end
        fail "for now, python-style strictness is enforced with indenting #{
          }of shell-style comments. expected the following line to start #{
          }with #{ line_header.inspect } : #{ line.inspect }"
      end while nil
      res
    end
  end


  class Sexp::Prototype::C_Style < Sexp::Prototype::Hack

    # (nothing public defined here.)

  protected

    fun = Sexp::Prototype::FUN
    rex = fun.rex
    line_rx = fun.line_rx
    end_of_multiline_rx = %r{ . (?= \*/ | ^[ \t]*$ ) }mx # explained below

    define_method :attempt_to_scan_multiline_example_body! do

      @deindent ||= -> do                      # for this nerk we require that
        if '' == line_header                   # the body of the example be
          -> s { s }                           # indented to times two (2x)
        else                                   # that which the keyword was
          _rx = /^(?:#{ rex[ line_header ] }){2}/ # indented.  it sounds crazy
          -> s do                              # but it is what looks best.
            res = nil
            md = _rx.match s
            if md
              res = md.post_match
            else
              fail "for now, actual python-style strictness is enforced with #{
                }an iron fist when parsing embedded examples in c-style #{
                }comments. expected the following line to match #{
                }\"/#{ _rx.source }/\" : #{ s.inspect }"
            end
            res
          end
        end
      end.call
                                               # so what you have is the scanner
      res = nil                                # at the point right after
      body = self.scn.scan_until end_of_multiline_rx # (the keyword and maybe
      if body                                  # a colon and the newline str).
        scn = ::StringScanner.new body         # (yes, it's easier this way)
        lines = []                             # Please scan up until and
        line = scn.scan line_rx                # including *either* (the last
        while line                             # character before the comment-
          line = @deindent[ line ]             # ending token '*/') -OR_ the
          if line                              # first blank line, whichever
            lines.push line                    # first.  And then inside of that
            line = scn.scan line_rx            # with each line enforce our
          end                                  # de-indenting and etc.
        end
        if ! lines.empty?
          res = lines.join ''
        end
      end
      res
    end
  end


  module Sexp::Prototype::Hub_InstanceMethods  # Here we turn an ordinary
                                               # sexp object into a veritable
    def _named_prototypes                      # powerhouse for holding all
      @_named_prototypes ||= { }               # of our prototypes found during
    end                                        # this hack.

    def set_named_prototype! name, prototype # no normalization here..
      if _named_prototypes.key? name
        fail "name collision: #{ name }"
      else
        _named_prototypes[name] = prototype
      end
    end
  end
end
