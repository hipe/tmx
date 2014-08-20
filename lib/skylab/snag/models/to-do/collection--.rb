module Skylab::Snag

  class Models::ToDo

    module Collection__

      class << self

        def build_scan_via_a a
          Scan__.new a
        end
      end

  class Scan__  # #borrow:2

    Listener = Snag_::Model_::Listener.new :command_string, :error_event

    Snag_::Model_::Actor[ self ]

    def initialize a  # paths patterns names
      @command = Snag_::Models::Find.new( * a.shift( 3 ) )
      @listener = Listener.via_iambic a
    end

    attr_reader :command, :exitstatus, :result, :seen_count

    def each
      if block_given?
        scn = to_scanner ; x = nil
        yield x while x = scn.gets
        @result
      else
        to_enum
      end
    end

    def to_scanner
      @seen_count = 0 ; @result = nil
      @p = bld_initial_gets_proc
      Callback_::Scn.new do
        @p[]
      end
    end
  private
    def bld_initial_gets_proc
      -> do
        @result = talk_to_command
        @result and procede_with_normal_scan
      end
    end
    def procede_with_normal_scan
      @p = bld_money_gets_proc
      @p[]
    end
    def talk_to_command
      ok = resolve_command_pattern
      ok && resolve_command_string
    end
    def resolve_command_pattern
      @command.pattern -> ok_x do
        @pattern_s = ok_x ; ACHIEVED_
      end, -> ev do
        send_error_event ev
      end
    end
    def resolve_command_string
      @command.command -> cmd_s do
        @command_s = cmd_s
        @listener.receive_command_string cmd_s
        ACHIEVED_
      end, -> ev do
        send_error_event ev
      end
    end
    def bld_money_gets_proc
      -> do
        fly = Collection__::Flyweight__.new @pattern_s
        _i, o, e, wait = Snag_::Library_::Open3.popen3 @command_s
        @p = -> do
          if o
            o_line = o.gets
            o_line or o = nil
          end
          if e
            e_line = e.gets
            e_line or e = nil
          end
          if e
            send_unexpected_output_error_event e_line
          end
          if o
            o_line.chomp!
            fly.replace o_line
            if e
              flush_more_e e
            end
            @seen_count += 1
            fly
          elsif e
            flush_more_e e
            @exitstatus = wait.value.exitstatus
            @result = UNABLE_
          else
            @exitstatus = wait.value.exitstatus
            @result = ACHIEVED_
            @p = EMPTY_P_ ; nil
          end
        end
        @p[]
      end
    end
    def send_unexpected_output_error_event line
      send_error_event :unexpected_output, :line, line do |y, o|
        y << "(unexpected output: #{ line.chomp })"
      end
    end
    def flush_more_e io
      self._DO_ME  # #todo
    end
  end
    end  # #pay-back:2
  end
end
