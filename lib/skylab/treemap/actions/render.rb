module Skylab::Treemap
  class FileLinesEnumerator < Enumerator
    def close_if_open
      @file.closed? ? nil : (@file.close || true)
    end
    attr_reader :index
    def initialize fh, &blk
      blk and raise ArgumentError("not today.  not today.")
      fh.closed? and fail("pass me an open filehandle please: #{fh.inspect}")
      @index = -1
      @file = fh
      super() do |y|
        @file.lines.each_with_index do |line, index|
          @index = index
          y << line.chomp
        end
      end
    end
  end
  class Actions::Render < Action
    attribute :char, required: true, regex: [/^.$/, 'must be a single character']
    attribute :path, path: true, required: true

    def advance_to_first_line
      found = false
      begin
        loop do
          (found = (@first_line_re =~ @lines.peek)) ? break : @lines.next
        end
      rescue StopIteration
      end
      found or error("#{pre attributes[:char].label}" <<
        " not found at the start of any line in #{path.pretty}.")
    end

    def clear!
      super
      @line_re = @first_line_re = nil
      if instance_variable_defined?('@lines') and @lines
        @lines.close_if_open
        @lines = nil
      end
      (@stack ||= []).clear
      @tree = nil
      self
    end

    def execute path, opts
      clear!.update_parameters!(opts.merge(path: path)).validate or return false
      (path = self.path).exist? or return error("input file not found: #{path.pretty}")
      @lines = FileLinesEnumerator.new(path.open('r'))
      @first_line_re = /\A[[:space:]]*#{Regexp.escape(char)} /
      @line_re = /\A(?<indent>[[:space:]]*#{Regexp.escape(char)} )(?<line_content>.*)\z/
      advance_to_first_line or return false
      read_lines or return false
      render_debug
      emit(:payload, "wow! you're great.")
    end

    def parse_error msg
      error("parse failure: #{msg} (in #{path.pretty})")
    end

    def parse_line line, index
      if md = @line_re.match(line)
        result = Hash[ * md.names.map { |n| [n.intern, md[n]] }.flatten ]
        result[:line_number] = index + 1
        result
      end
    end

    def read_lines
      @stack.empty? or fail("for now, won't read_lines unless stack is empty")
      @stack.push Skylab::Treemap::Models::Node.new
      @stack.last.push Skylab::Treemap::Models::Node.new
      loop do
        line = begin @lines.next; rescue StopIteration ; break end
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
    def render_debug
      require 'skylab/porcelain/tree'
      i = 0
      Skylab::Porcelain::Tree.text(@tree) do |line|
        i += 1
        $stderr.puts line
      end
      0 == i and info("(nothing)")
      i
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
        a.push "that of line #{@stack.last.last.line_number}"
      end
      parse_error("bad indentation on line #{node.line_number} --" <<
        " it must be #{a.join(' or ')}")
    end
  end
end

