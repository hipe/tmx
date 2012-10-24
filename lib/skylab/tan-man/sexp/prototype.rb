module ::Skylab::TanMan
  module Sexp::Prototype
    # Check out this wondrously obtuse hack: if you have a member called
    # "foo_bar" that turns up nil in a parse, and its immediately previous
    # member is a string that looks like a shell-style comment, and at the
    # beginning of its content appears the string "example foo_bar:"
    # then we will fire up a new parser and parse that string and use it
    # as your foo_bar!!!!!!!111
    #
  end

  class << Sexp::Prototype
    def match prev_tree, tree_class, member
      ::String === prev_tree or return
      scn = ::StringScanner.new prev_tree
      scn.skip(/[\r\n]+/)
      line_header = scn.scan(/[ \t]*#[ \t]*/) or return
      scn.skip(/example /) or return # the logical cutoff could be wherever
      Sexp::Prototype::Hack.new(scn, line_header, member, tree_class)
    end
  end

  class Sexp::Prototype::Hack < ::Struct.new(:scn, :line_header,
                                             :member, :tree_class)
    def commit!
      name = scn.scan(/[a-z_][a-z0-9_]*/) or return
      name.intern == member or return
      string = read_embedded_string or fail('sanity')
      parser = tree_class.grammar.build_parser_for_rule member
      result = parser.parse string
      if ! result
        fail("when parsing your #{member} prototype embedded in a comment: #{
          parser.failure_reason}")
      else
        sexp = tree_class.element2tree result, member
        if sexp.list?
          sexp._prototypify!
        else
          fail("implement me -- prototypes for non-list rules")
        end
      end
    end

  protected

    def read_embedded_string
      str = read_single_line_embedded_string
      str ||= read_multi_line_embedded_string
      str
    end

    def read_multi_line_embedded_string
      # If there is no content after the ':' in "example foo_bar:", use this.
      # For now, must return non-nil or fail
      #
      scn.skip(/[ \t]*/) # chomp any trailing _spaces_ after the ':'
      len = scn.match?(/\r?\n/) or fail('expecting newline in comment')
      newline = scn.peek len
      line_sep_rx = /#{::Regexp.escape("#{newline}#{line_header}")}/
      a = []
      while scn.skip(line_sep_rx)
        # very experimental -- assume embedding ends on first blank comment line
        if some = scn.scan(/[^\r\n]+/)
          a.push some
        else
          break
        end
      end
      if newline == scn.peek(newline.length) # always consume the trailing n/l
        newline.length.times { scn.getch }
        a.push ''
      end
      a.join newline
    end

    def read_single_line_embedded_string
      # for if there is content after the ':' in "example foo_bar:"
      if scn.skip(/ *:/)
        if scn.match?(/[ \t]*[^ \t\n\r]/)
          scn.scan(/[^\n\r]+/) or fail('sanity')
        end
      end
    end
  end
end
