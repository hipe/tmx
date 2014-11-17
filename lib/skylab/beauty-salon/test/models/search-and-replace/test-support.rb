require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models

  ::Skylab::BeautySalon::TestSupport[ self ]

end

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  ::Skylab::BeautySalon::TestSupport::Models[ TS_ = self ]

  include Constants

  BS_ = BS_

  Callback_ = BS_::Callback_

  extend TestSupport_::Quickie

  module InstanceMethods

    # ~ setup

    def start_tmpdir
      td = existent_tmpdir
      @tmpdir = td.with(
        :path, td.join( 'haha-dir' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )
      nil
    end

    def to_tmpdir_add_wazoozle_file
      @tmpdir.write 'ok-whatever-wazoozle.txt', unindent( <<-O )
        ok oh my geez --> HAHA <--
      O
      nil
    end

    def start_tmpdir_SKIP
      @tmpdir = existent_tmpdir.join 'haha-dir'
      nil
    end

    # ~ interactive run

    def start_session path
      @session = Session__.new( self, path ).start
      nil
    end

    # ~ non-interactive run

    def call_API * x_a
      evr = event_receiver
      x_a.push :on_event_selectively, -> * , & ev_p do
        ev = ev_p[]
        evr.receive_event ev
        ev.ok
      end
      @result = _API.call( * x_a )
      nil
    end

    def _API
      Subject_[]::API
    end

    def event_expression_agent
      BS_::Lib_::Brazen[]::API.expression_agent_instance
    end

    # ~ assertion support

    def unindent s
      s.gsub! UNINDENT_RX__, BS_::EMPTY_S_
      s
    end
    UNINDENT_RX__ = %r(^[ ]+)

  end

  class Session__

    def initialize test_context, path
      @chdir_path = path
      @test_context = test_context
      @ok = true
    end

    def start
      @in, @out, @err, @thread = BS_::Lib_::Open3[].popen3 Bin_path_[],
        chdir: @chdir_path
      self
    end

    def puts line
      if @ok
        @in.puts line
        nil
      end
    end

    def gets
      if @ok
        @err.gets
      end
    end

    def expect_line_eventually rx
      if @ok
        do_expect_line_eventually rx
      end
    end

    def do_expect_line_eventually rx
      found = false
      count = 0
      while line = @err.gets
        count += 1
        if rx =~ line
          found = true
          break
        end
      end
      if ! found
        @ok = false
        raise "never found line in #{ count } lines,\n#{ rx.inspect }\nlast line: #{ line.inspect }"
      end
    end

    def close
      @out.close
      @err.close
    end
  end

  Bin_path_ = Callback_.memoize do
    BS_::Lib_::System[].defaults.bin_pathname.
      join( 'tmx-beauty-salon search-and-r' ).to_path
  end

  Subject_ = -> do
    BS_::Models_::Search_and_Replace
  end

  SLASH_ = '/'.freeze

  THREE_LINES_FILE_ = 'three-lines.txt'.freeze

end

module Skylab::BeautySalon::TestSupport::Models

  S_and_R = Search_and_Replace

end
