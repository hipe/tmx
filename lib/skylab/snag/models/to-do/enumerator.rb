module Skylab::Snag

  class Models::ToDo::Enumerator < ::Enumerator

    extend PubSub::Emitter

    emits :error, :command

    event_factory Snag::API::Events::Datapoint

    # (primary public method is `each` whose private impl is `visit`)

    #         ~ courtesy reflection & rendering (in asc. complexity) ~

    attr_reader :command

    attr_reader :seen_count

  private

    def initialize paths, names, pattern
      @seen_count = nil
      @command = Snag::Services::Find.new paths, names, pattern
      super(& method( :visit ) )
    end

    def visit y  # ( methods presented in pre-order from here )
      res = false
      if all_required_events_are_handled
        res = true
        @seen_count = 0
        err = -> e { emit :error, e ; res = false }
        @command.pattern -> p do
          @pattern = p
          @command.command -> cmd do
            emit :command, cmd
            visit_valid y, cmd
          end, err
        end, err
      end
      res  # ick i hate semantic results from iterators..
    end

    def all_required_events_are_handled
      if_unhandled_stream_names -> a do
        msg = "strict about event coverage for now - unhandled: #{ a * ', ' }"
        if a.include? :error
          raise ::RuntimeError, msg
        else
          emit :error, msg
        end
      end, -> do  # else
        true
      end
    end

    def visit_valid y, cmd
      res = true
      Snag::Services::Open3.popen3( cmd ) do |sin, sout, serr|
        todo = Models::ToDo::Flyweight.new @pattern
        sout.each_line do |line|
          @seen_count += 1
          y << todo.replace( line.chomp )
        end
        serr.each_line do |line|
          res = false
          emit :error, "(unexpected output: #{ line.chomp })"
        end
      end
      res
    end
  end
end
