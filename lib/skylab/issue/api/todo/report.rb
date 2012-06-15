module Skylab::Issue
  Todo = Api::Todo # yeah, this sad problem.  or is it a pattern!?

  class Todo::Report < Api::Action
    emits :all, error: :all, info: :all, payload: :all

    attribute :paths, required: true

    def execute
      params! or return
      Todo::TodoEnumerator.new(paths).each do |todo|
        payload "yes: #{todo}"
      end
    end

    def payload msg
      emit(:payload, msg)
    end
  end

  class Todo::Todo
    def initialize
    end
    def set! string
      @string = string
      self
    end
    attr_reader :string
    alias_method :to_s, :string
  end

  class Todo::TodoEnumerator < Enumerator
    def initialize(paths)
      block_given? and raise ArgumentError.new("don't pass blocks to this.")
      super() do |y|
        y << (t = Todo::Todo.new.set!("one"))
        y << t.set!("two")
        y << t.set!("three")
      end
    end
  end
end

