module Skylab::TanMan

  Operations_ = ::Module.new

  class Operations_::StackViz

    def initialize argv, streamer, client

      @argv = argv
      @client = client
      @streamer = streamer

      @_do_open = false
    end

    def execute

      @_mixed_result = 0
      stay = __process_argv
      stay && __init_listener
      stay &&= __init_graph_line_stream
      stay && __via_graph_line_stream
      @_mixed_result
    end

    def __process_argv
      if @argv.length.zero?
        ACHIEVED_
      else
        __process_nonzero_length_argv
      end
    end

    def __process_nonzero_length_argv

      require 'optparse'
      op = ::OptionParser.new

      did_request_help = false
      do_open = false

      op.on '-h', '--help', 'this.' do
        did_request_help = true
      end

      op.on '-o', '--open', 'will attempt to open the file' do
        do_open = true
      end

      begin
        op.parse! @argv
      rescue ::OptionParser::ParseError => e
      end

      if e
        __when_parse_error e
      elsif did_request_help
        __when_did_request_help op
      else
        @_do_open = true
        STAY_
      end
    end

    def __when_did_request_help op
      io = @client.stderr
      io.puts "usage: #{ _my_program_name } [options]"
      io.puts
      io.puts "synsopsis: hackish experiment .."
      io.puts
      io.puts "options:"
      op.summarize( & io.method( :puts ) )
      DONE_
    end

    def __when_parse_error e
      @client.stderr.puts e.message
      @client.stderr.puts "use `#{ _my_program_name } -h` for help."
      @_mixed_result = 5
      DONE_
    end

    def _my_program_name
      "#{ @client.program_name } viz"
    end

    # --

    def __via_graph_line_stream
      st = remove_instance_variable :@__graph_line_stream
      if @_do_open
        __open st
      else
        @_mixed_result = st
        NIL
      end
    end

    def __open st
      line = st.gets
      if line
        __do_open line, st
      else
        @client.serr.puts "(no lines for graph)"
        @_mixed_result = 6
      end
      NIL
    end

    def __do_open line, st
      path = 'tmp.dot'  # meh
      io = ::File.open path, ::File::CREAT | ::File::TRUNC | ::File::WRONLY
      begin
        io.write line
        line = st.gets
        line ? redo : break
      end while above
      io.close
      exec 'open', path
      self._NEVER_SEE
    end

    def __init_graph_line_stream

      _st = @streamer.call
      _st = Home_::StackMagnetics_::ItemStream_via_LineStream[ _st, & @listener ]
      _gr = Home_::StackMagnetics_::Graph_via_ItemStream[ _st, & @listener ]
      _st = Home_::StackMagnetics_::LineStream_via_Graph[ _gr, & @listener ]
      _store :@__graph_line_stream, _st
    end

    def __init_listener

      io = nil ; y = nil
      once = -> do
        once = nil
        io = @client.serr
        y = ::Enumerator::Yielder.new do |msg|
          io.puts msg
        end ; nil
      end

      @listener = -> * i_a, ev_p do
        once && once[]
        if :expression == i_a.fetch(1)
          nil.instance_exec( y, & ev_p )
          y
        else
          y << i_a.inspect
        end
      end ; nil
    end

    def _store ivar, x
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    DONE_ = false
    STAY_ = true
  end
end
