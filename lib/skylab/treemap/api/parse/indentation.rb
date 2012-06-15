module Skylab::Treemap
  class API::Parse::Indentation
    extend Skylab::PubSub::Emitter
    emits parse_error: :all

    include Bleeding::Styles # smell

    def self.invoke(*a, &b)
      new(*a, &b).invoke
    end

    def advance_to_first_line
      @lines.peeking.detect { |line| @first_line_re =~ line } or
        parse_error("#{pre attributes[:char].label}" <<
          " not found at the start of any line (of #{@lines.index + 1})")
    end

    attr_reader :attributes

    attr_reader :char

    def clear!
      @line_re = @first_line_re = nil
      if instance_variable_defined?('@lines') and @lines
        @lines.close_if_open
        @lines = nil
      end
      (@stack ||= []).clear
      @tree = nil
      self
    end

    def initialize attributes, path, char
      @attributes = attributes
      @path = path
      @char = char
      yield self
    end

    def invoke
      clear!
      @lines = API::FileLinesEnumerator.new(path.open('r'))
      @first_line_re = /\A[[:space:]]*#{Regexp.escape(char)} /
      @line_re = /\A(?<indent>[[:space:]]*#{Regexp.escape(char)} )(?<line_content>.*)\z/
      advance_to_first_line or return false
      read_lines or return false
      @tree
    end

    def parse_error msg
      emit(:parse_error, "parse failure: #{msg} (in #{path.pretty})")
      false
    end

    def parse_line line, index
      if md = @line_re.match(line)
        result = Hash[ * md.names.map { |n| [n.intern, md[n]] }.flatten ]
        result[:line_number] = index + 1
        result
      end
    end

    attr_reader :path

    def read_lines
      @stack.empty? or fail("for now, won't read_lines unless stack is empty")
      @stack.push Skylab::Treemap::Models::Node.new
      @stack.last.push Skylab::Treemap::Models::Node.new
      @lines.peeking.each do |line|
        data = parse_line(line, @lines.index) or break
        node = Skylab::Treemap::Models::Node.new(data)
        case @stack.last.first.indent_length <=> node.indent.length
        when -1 ; @stack.last.last.push(node)
                ; @stack.push(@stack.last.last)
        when  0 ; @stack.last.push(node)
        when  1 ; stack_pop(node) or return false # careful!
        else    ; fail('no')
        end
      end
      1 == @stack.first.children_length or fail("no")
      @tree = @stack.first.first
      if 1 == @tree.children_length # prune lone roots
        @tree = @tree.first
      end
      @stack = nil
      true
    end

    def stack_pop node
      loop do
        was = @stack.pop
        case @stack.last.first.indent_length <=> node.indent.length
        when -1 ; return stack_pop_error_indent(node, was)
        when  0 ; @stack.last.push(node) ; return true
        when  1 ; @stack.length <= 2 and return stack_pop_error_deindent(node)
        else    ; fail('no')
        end
      end
    end
    def stack_pop_error_deindent node
      parse_error("too little indentation on line #{node.line_number} --" <<
        " it got behind the indentation established on line #{@stack.last.first.line_number}")
    end
    def stack_pop_error_indent node, was
      (a = []).push "that of line #{was.last.line_number}"
      if @stack.length > 1
        a.push " or that of line #{@stack.last.last.line_number}"
      end
      if @stack.length > 2
        a.push " (etc)"
      end
      parse_error("bad indentation on line #{node.line_number} --" <<
        " it must be #{a.join('')}")
    end
  end
end

