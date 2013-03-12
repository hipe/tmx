module Skylab::Treemap

  class Services::File::Indented::Parse  # (was [#027])

    extend PubSub::Emitter

    emits parse_error: :all

    event_factory PubSub::Event::Factory::Datapoint

    def self.[] attributes, char, pathname, stylus, error
      o = new attributes, char, pathname, stylus, error
      o.send :execute
    end

    include Treemap::Core::SubClient::InstanceMethods

    # --*--

  protected

    def initialize attributes, char, pathname, stylus, error
      block_given? and fail 'no'
      @attributes, @char, @stylus = attributes, char, stylus
      @lines = @line_rx = @first_line_rx = nil
      @pathname = ( ::Pathname.new( pathname ) if pathname )
      @stack = [ ]
      @stylus = stylus
      on_parse_error( &error ) if error # super sneaky
      nil
    end

    def advance_to_first_line
      res = @lines.peeking.detect { |line| @first_line_rx =~ line }
      if ! res
        res = parse_error "#{ pre @attributes.fetch(:char).label_string } #{
          }not found at the start of any line (of #{ @lines.index + 1 })"
      end
      res
    end

    def clear!
      @line_rx = @first_line_rx = nil
      if @lines
        @lines.close_if_open
        @lines = nil
      end
      @stack.clear
      @tree = nil
      nil
    end

    def execute
      res = nil
      begin
        clear!
        @lines = Services::File::Lines::Enumerator.new @pathname.open( 'r' )
        @first_line_rx = /\A[[:space:]]*#{ ::Regexp.escape @char } /
        @line_rx = /\A
          (?<indent> [[:space:]]* #{ ::Regexp.escape @char } )
          (?<content> .* )
        \z/x
        advance_to_first_line or break( res = false )
        read_lines or break( res = false )
        res = @tree
      end while nil
      res
    end

    def parse_error msg
      emit :parse_error, "parse failure: #{ msg } #{
        }(in #{ escape_path @pathname })"
      false
    end

    def parse_line line, index
      if md = @line_rx.match(line)
        result = ::Hash[ * md.names.map { |n| [n.intern, md[n]] }.flatten ]
        result[:line_number] = index + 1
        result
      end
    end

    def read_lines
      res = nil
      begin
        @stack.empty? or fail "for now, won't read_lines unless stack is empty"
        @stack.push Treemap::Models::Node.new
        @stack.last.push Treemap::Models::Node.new
        ok = true
        @lines.peeking.each do |line|
          prop_h = parse_line line, @lines.index
          prop_h or break
          node = Treemap::Models::Node.new prop_h
          case @stack.last.first.indent_length <=> node.indent.length
          when -1
            @stack.last.last.push node
            @stack.push @stack.last.last
          when  0
            @stack.last.push node
          when  1
            ok = stack_pop node
            ok or break
          end
        end
        break( res = false ) if ! ok
        fail "sanity" if 1 != @stack.first.children_length
        @tree = @stack.first.first
        if 1 == @tree.children_length # prune lone roots
          @tree = @tree.first
        end
        @stack = nil
        res = true
      end while nil
      res
    end

    def stack_pop node
      res = nil
      loop do
        was = @stack.pop
        case @stack.last.first.indent_length <=> node.indent.length
        when -1
          break( res = stack_pop_error_indent node, was )
        when  0
          @stack.last.push node
          break( res = true )
        when  1
          if @stack.length <= 2
            break( res = stack_pop_error_deindent node )
          end
        end
      end
      res
    end

    def stack_pop_error_deindent node
      parse_error "too little indentation on line #{ node.line_number } -- #{
        }it got behind the indentation established on line #{
        }#{ @stack.last.first.line_number }"
    end

    def stack_pop_error_indent node, was
      a = [ "that of line #{ was.last.line_number }" ]
      if @stack.length > 1
        a << " or that of line #{ @stack.last.last.line_number }"
      end
      if @stack.length > 2
        a << " (etc)"
      end
      parse_error "bad indentation on line #{ node.line_number } -- #{
        }it must be #{ a.join '' }"
    end

    attr_reader :stylus           # you have no request_client so yet, this.
  end
end
