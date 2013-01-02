module Skylab::Snag
  class Models::ToDo::Enumerator < ::Enumerator
    extend PubSub::Emitter

    emits :err

    attr_reader :command

    attr_reader :last_count

  protected

    def initialize paths, names, pattern
      block_given? and fail 'sanity'
      @command = Models::ToDo::Command.new paths, names, pattern
      super() do |y|
        Snag::Services::Open3.popen3( @command.string ) do |sin, sout, serr|
          todo = Models::ToDo::Item.new
          @last_count = 0
          sout.each_line do |line|
            @last_count += 1
            y << todo.set!( line.chomp )
          end
          serr.each_line do |line|
            emit :err, line.chomp
          end
        end
      end
    end
  end
end
