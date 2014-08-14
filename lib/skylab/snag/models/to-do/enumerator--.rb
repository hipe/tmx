module Skylab::Snag

  class Models::ToDo::Enumerator__ < ::Enumerator

    Callback_[ self, :employ_DSL_for_digraph_emitter ]

    listeners_digraph :error, :command

    event_factory Snag_::API::Events::Datapoint

    # (primary public method is `each` whose private impl is `visit`)

    #         ~ courtesy reflection & rendering (in asc. complexity) ~

    def initialize paths, pattern, names
      @command = Snag_::Library_::Find.new paths, pattern, names
      @seen_count = nil
      super(& method( :visit ) )
    end

    attr_reader :command

    attr_reader :seen_count

  private

    def visit y  # ( methods presented in pre-order from here )
      res = false
      if all_required_events_are_handled
        res = true
        @seen_count = 0
        err = -> e { call_digraph_listeners :error, e ; res = false }
        @command.pattern -> p do
          @pattern = p
          @command.command -> cmd do
            call_digraph_listeners :command, cmd
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
          call_digraph_listeners :error, msg
        end
      end, -> do  # else
        true
      end
    end

    def visit_valid y, cmd
      res = true
      Snag_::Library_::Open3.popen3( cmd ) do |sin, sout, serr|
        todo = self.class::Flyweight__.new @pattern
        sout.each_line do |line|
          @seen_count += 1
          y << todo.replace( line.chomp )
        end
        serr.each_line do |line|
          res = false
          call_digraph_listeners :error, "(unexpected output: #{ line.chomp })"
        end
      end
      res
    end
  end
end
