module Skylab::TanMan

  class Operations_::StackViz

    def initialize argv, streamer, client

      @__mutex_for_exitstatus = nil

      @_do_open = false
      @_last_N = nil

      @argv = argv
      @client = client
      @streamer = streamer
    end

    def execute

      ok = __process_argv
      ok && __init_listener
      ok &&= __resolve_line_upstream
      ok && __init_item_stream_via_line_upstrem_stream
      if ok
        d = remove_instance_variable :@_last_N
        if d
          ok = __reduce_item_stream_by_this d
        end
      end
      ok && __init_graph_via_item_stream
      ok && __init_graph_linesteam_via_graph
      ok && __via_graph_line_stream
      remove_instance_variable :@__exitstatus
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
      last_N = nil

      op.on '-l', '--last N', 'only look at the last N items on the stack', ::Integer do |d|
        last_N = d
      end

      op.on '-o', '--open', 'will attempt to open the file' do
        do_open = true
      end

      op.on '-h', '--help', 'this screen (help for "viz").' do
        did_request_help = true
      end

      begin
        op.parse! @argv
      rescue ::OptionParser::ParseError => e
      end

      if e
        __when_parse_error e
      elsif did_request_help
        if ( do_open || last_N )
          @client.stderr.puts "(ignoring some options)"
        end
        __when_did_request_help op
      else
        @_last_N = last_N
        @_do_open = do_open
        ACHIEVED_
      end
    end

    def __when_did_request_help op

      puts = @client.stderr.method :puts
      y = ::Enumerator::Yielder.new( & puts )
      y << "usage: #{ _my_program_name } [options]"
      y << nil
      y << "synsopsis: hackish experiment: those"
      Home_::StackMagnetics_::ItemStream_via_LineStream::Describe_that_one_rx[ y ]
      y << "will be used to define a dependency graph illustrating"
      y << "the interdependencies between the items."
      y << "(note that the maximum number of participating nodes is"
      y << "intentionally limited to 26.)"
      y << nil
      y << "options:"
      op.summarize( & puts )
      _exit_early
    end

    def __when_parse_error e
      @client.stderr.puts e.message
      @client.stderr.puts "use `#{ _my_program_name } -h` for help."
      _fail
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
        puts = @client.stdout.method :puts
        line = nil
        puts line while ( line = st.gets )
        __succeed
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

    def __init_graph_linesteam_via_graph
      _ = remove_instance_variable :@__graph
      @__graph_line_stream = Home_::StackMagnetics_::
        LineStream_via_Graph[ _, & @listener ]
      NIL
    end

    def __init_graph_via_item_stream
      _ = remove_instance_variable :@_item_stream
      @__graph = Home_::StackMagnetics_::Graph_via_ItemStream[ _, & @listener ]
      NIL
    end

    def __reduce_item_stream_by_this d
      0 < d or self._COVER_ME__last_N_value_must_be_positive_nonzero__
      upstream = remove_instance_variable :@_item_stream
      count = 0
      @_item_stream = Common_.stream do
        if count < d
          count += 1
          upstream.gets
        end
      end
      ACHIEVED_
    end

    def __init_item_stream_via_line_upstrem_stream
      _line_st = remove_instance_variable :@__line_upstream
      @_item_stream = Home_::StackMagnetics_::
        ItemStream_via_LineStream[ _line_st, & @listener ]
      NIL
    end

    def __resolve_line_upstream
      _str = remove_instance_variable :@streamer
      _my_store :@__line_upstream, _str.call
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

      @listener = -> * sym_a, ev_p do
        once && once[]
        if :expression == sym_a.fetch(1)
          nil.instance_exec( y, & ev_p )
          y
        else
          y << sym_a.inspect
        end
      end ; nil
    end

    # --

    def _my_store ivar, x  # compare DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        _fail
      end
    end

    def _fail
      _receive_exitstatus 5
      DONE_
    end

    def _exit_early
      _receive_exitstatus 0
      DONE_
    end

    def __succeed
      _receive_exitstatus 0
      ACHIEVED_
    end

    def _receive_exitstatus d
      remove_instance_variable :@__mutex_for_exitstatus
      @__exitstatus = d ; nil
    end

    # ==

    DONE_ = false
  end
end
