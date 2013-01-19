module Skylab::Snag
  class Models::ToDo::Enumerator < ::Enumerator
    extend PubSub::Emitter

    emits :stderr_line

    attr_reader :command

    def names
      @command.names
    end

    def paths
      @command.paths
    end

    def pattern
      @command.pattern
    end

    def render_description_pp_for client # like [#029]
      me = self
      client.instance_exec do
        a = [ "in #{ and_ me.paths.map { |p| val p } }" ]
        if me.names.length.nonzero?
          a << "named #{ or_ me.names.map { |n| val n } }"
        end
        a << "with the pattern #{ val me.pattern }"
        a.join ' '
      end
    end

    attr_reader :seen_count

  protected

    def initialize paths, names, pattern
      block_given? and fail 'sanity'
      @seen_count = nil
      @command = Models::ToDo::Command.new paths, names, pattern
      super( ) do |y|
        visit y
      end
    end

    def visit y
      res = true
      Snag::Services::Open3.popen3( @command.render ) do |sin, sout, serr|
        todo = Models::ToDo::Flyweight.new @command.pattern
        @seen_count = 0
        sout.each_line do |line|
          @seen_count += 1
          y << todo.set!( line.chomp )
        end
        serr.each_line do |line|
          res = false
          emit :stderr_line, line.chomp
        end
      end
      res
    end
  end
end
