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
    def match prev_tree, curr_tree, tree_class, member
      result = nil
      begin
        ::String === prev_tree or break
        scn = ::StringScanner.new prev_tree
        scn.skip( /[\r\n]+/ )
        line_header = scn.scan( /[ \t]*#[ \t]*/ )
        if line_header
          klass = Sexp::Prototype::ShellStyle
        elsif scn.skip(%r<[ \t]*/\*>)
          klass = Sexp::Prototype::C_Style
          scn.skip( /([ \t]*[\r\n]+)+/ )
          line_header = scn.scan( /[ \t]*/ )
        else
          break
        end
        scn.skip( /example / ) or break # the logical cutoff could be wherever
        result = klass.new scn, curr_tree, line_header, member, tree_class
      end while nil
      result
    end
  end

  class Sexp::Prototype::Hack < ::Struct.new(:scn, :curr_tree, :line_header,
                                             :member, :tree_class)
    LINE_RX = /[^\r\n]*\r?\n|[^\r\n]+\r?\n?/
    NAME_RX = /[_a-z][_a-z0-9]*/i

    def commit!
      result = nil
      begin
        name = scn.scan( /[a-z_][a-z0-9_]*/ ) or break
        name.intern == member or break
        string = read_embedded_string! or fail 'sanity'
        parser = tree_class.grammar.build_parser_for_rule member
        result = parser.parse string
        result or fail "when parsing your #{ member } prototype embedded in #{
          }a comment: #{ parser.failure_reason }"
        sexp = tree_class.element2tree result, member
        if sexp.list?
          self.list_controller = sexp._prototypify! curr_tree
          parse_the_rest!
          result = list_controller
        else
          fail "implement me -- prototypes for non-list rules"
        end
      end while nil
      result
    end

  protected
    attr_accessor :list_controller

    def parse_example!
      a = [ ]
      2.times do
        scn.skip(/[ \t]+/)
        s = scn.scan(NAME_RX) and a.push s
      end
      a.length >= 1 or fail("expecting rule near #{scn.rest[0..10].inspect}")
      rule = a.pop.intern
      label = a.pop and label = label.intern
      a = [rule, label].compact
      string = read_embedded_string! or fail('sanity')
      p = tree_class.grammar.build_parser_for_rule rule
      p.consume_all_input = false # hack to allow trailing newlines
      result = p.parse string
      failure_reason = if ! result
        p.failure_reason
      elsif p.input.length > p.index
        s = p.input[p.index .. -1]
        /[^[:space:]]/ =~ s and "could not parse: #{s.inspect}"
      end
      failure_reason and fail("when parsing your #{a.join(' ')
        } prototype embedded in a comment: #{p.failure_reason}")
      sexp = tree_class.element2tree result, (label || rule) # FUCK
      list_controller.set_named_prototype!(label || rule, sexp)
      nil
    end

    def parse_the_rest!
      embedded_string = read_and_normalize_remaining_string!
      self.scn = ::StringScanner.new embedded_string # ofuck
      scn.skip(/[ \t]*\r?\n/)
      until scn.eos?
        if scn.skip(/[ \t]*example /)
          parse_example!
        else
          scn.skip(LINE_RX) or fail('huh?')
        end
      end
      nil
    end

    def read_embedded_string!
      str = read_single_line_embedded_string!
      str ||= read_multi_line_embedded_string!
      str
    end

    def read_single_line_embedded_string!
      # for if there is content after the ':' in "example foo_bar:"
      if scn.skip(/ *:/)
        if scn.match?(/[ \t]*[^ \t\n\r]/)
          scn.skip(/[ \t]/) # only one ack!!
          scn.scan(/[^\n\r]+/) or fail('sanity')
        end
      end
    end

    def read_multi_line_embedded_string!
      # If there is no content after the ':' in "example foo_bar:", use this.
      # For now, must result in non-nil or fail
      #
      scn.skip(/[ \t]*/) # chomp any trailing _spaces_ after the ':'
      len = scn.match?(/\r?\n/) or fail('expecting newline in comment')
      newline = scn.peek len
      line_sep_rx = /#{::Regexp.escape("#{newline}#{line_header}")}/
      a = []
      while scn.skip(line_sep_rx)
        # very experimental -- assume embedding ends on first blank comment line
        if some = scn.scan(/[^\r\n]+/)
          a.push deindent(some)
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
  end

  class Sexp::Prototype::ShellStyle < Sexp::Prototype::Hack
  protected
    def deindent line
      line # we don't de-indent lines in shell style for now
    end
    def read_and_normalize_remaining_string!
      a = [ ]
      begin
        if scn.skip(/[\r\n]*[ \t]*#/)
          a.push scn.scan(/[^\r\n]*\r?\n?/)
        else
          scn.skip(LINE_RX) or fail('wahh')
        end
      end while ! scn.eos?
      self.line_header = line_header[(line_header.index('#') + 1)..-1] # omg
      a.join('')
    end
  end

  class Sexp::Prototype::C_Style < Sexp::Prototype::Hack
  protected
    def deindent line
      # we require that lines are python-style indented here for now
      if 0 != line.index(line_header)
        fail("expecting indend of #{line_header.inspect} on line: #{
          line.inspect}")
      end
      line[line_header.length .. -1]
    end
    def read_and_normalize_remaining_string!
      a = [ ]
      while s = scn.scan_until(%r<.(?=\*/)>m)
        a << s
        scn.skip_until(%r</\*>)
      end
      a.join('')
    end
  end

  module Sexp::Prototype::SexpInstanceMethods
    def _named_prototypes
      @_named_prototypes ||= { }
    end

    def set_named_prototype! name, prototype
      _named_prototypes.key?(name) and fail("name collision: #{name}")
      _named_prototypes[name] = prototype
    end
  end
end
