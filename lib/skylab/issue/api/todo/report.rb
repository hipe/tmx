module Skylab::Issue

  # (below line kept for #posterity, is is the twinkle in the eye of the
  # [#sl-123] convention)
  # Todo = Api::Todo # yeah, this sad problem.  or is it a pattern!?

  class Api::Todo::Report < Api::Action
    emits :all, error: :all, info: :all, payload: :all,
           number_found: :all

    attribute :show_command
    attribute :names, required: true, default: ['*.rb']
    attribute :paths, required: true
    attribute :pattern, required: true, default: '@todo\>'

    def execute
      enum = Api::Todo::TodoEnumerator.new(paths, names, pattern)
      if show_command
        emit(:payload, enum.command)
        return true
      end
      enum.on_err { |e| emit(:info, e) }
      enum.each do |todo|
        emit(:payload, todo)
      end
      emit(:number_found, count: enum.last_count)
      true
    end
  end

  class Api::Todo::Todo
    def content
      @rest.nil? and parse!
      @rest
    end
    def dup
      self.class.new.set! @string
    end
    def initialize
      set! nil
    end
    def line
      @line.nil? and parse!
      @line
    end
    REGEX = /\A(?<path>[^:]+):(?<line>\d+):(?<rest>.*)$/
    def parse!
      if @string and md = REGEX.match(@string)
        @line = md[:line].to_i
        @path = md[:path]
        @rest = md[:rest]
      else
        @line = @path = @rest = false
      end
    end
    def path
      @path.nil? and parse!
      @path
    end
    def set! string
      @line = @path = @rest = nil
      @string = string
      self
    end
    attr_reader :string
    alias_method :to_s, :string
    def valid?
      if ! (@line && @path) and @string
        parse!
      end
      (@line && @path)
    end
  end

  class Api::Todo::SystemCommand < ::Struct.new :paths, :names, :pattern
    def string
      ["find #{paths.map(&:shellescape).join(' ')} \\(",
       names.map{ |n| "-name #{n.shellescape}" }.join(' -o '),
      "\\) -exec grep --line-number #{pattern.shellescape} {} +"
      ].join(' ')
      # find lib/skylab/issue -name '*.rb' -exec grep --line-number '@todo\>' {} +
    end
    alias_method :to_s, :string
  end

  class Api::Todo::TodoEnumerator < ::Enumerator
    attr_reader :command
    extend PubSub::Emitter
    emits :err
    def initialize paths, names, pattern
      block_given? and raise ArgumentError.new("don't pass blocks to this.")
      @command = Api::Todo::SystemCommand.new(paths, names, pattern)
      super() do |y|
        Issue::Services::Open3.popen3( @command.string ) do |sin, sout, serr|
          todo = Api::Todo::Todo.new
          @last_count = 0
          sout.each_line do |line|
            @last_count += 1
            y << todo.set!(line.chomp)
          end
          serr.each_line do |line|
            emit(:err, line.chomp)
          end
        end
      end
    end
    attr_reader :last_count
  end
end
