module Skylab::Snag

  class Models::ToDo::Enumerator__ < ::Enumerator

    Callback_[ self, :employ_DSL_for_digraph_emitter ]

    listeners_digraph :error_string, :command_string

    event_factory -> _, __, x { x }

    # (primary public method is `each` whose private impl is `visit`)

    #         ~ courtesy reflection & rendering (in asc. complexity) ~

    def initialize paths, pattern, names
      @command = Snag_::Models::Find.new paths, pattern, names
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
        err = -> ev do
          send_to_listener :error_event, ev
          res = false
        end
        @command.pattern -> p do
          @pattern = p
          @command.command -> cmd do
            send_to_listener :command_string, cmd
            visit_valid y, cmd
          end, err
        end, err
      end
      res  # ick i hate semantic results from iterators..
    end

    def all_required_events_are_handled
      if_unhandled_stream_names -> a do
        msg = "strict about event coverage for now - unhandled: #{ a * ', ' }"
        a.include? :error_string and raise ::RuntimeError, msg
        send_to_listener :error_string, msg
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
          y << ( todo.replace line.chomp )
        end
        serr.each_line do |line|
          res = false
          send_to_listener :error_string, "(unexpected output: #{ line.chomp })"
        end
      end
      res
    end

    def send_to_listener i, x
      call_digraph_listeners i, x
    end
  end
end
