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

    # ~ hook-out's for [br] "expect interactive"

    def interactive_bin_path
      Bin_path_[]
    end

    # ~ non-interactive run

    def call_API * x_a
      evr = event_receiver_for_expect_event
      x_a.push :on_event_selectively, -> * , & ev_p do
        ev = ev_p[]
        evr.receive_ev ev
        ev.ok
      end
      @result = _API.call( * x_a )
      nil
    end

    def _API
      Subject_[]::API
    end

    def black_and_white_expression_agent_for_expect_event
      BS_.lib_.brazen::API.expression_agent_instance
    end

    # ~ assertion support

    def unindent s
      s.gsub! UNINDENT_RX__, BS_::EMPTY_S_
      s
    end
    UNINDENT_RX__ = %r(^[ ]+)

  end

  Bin_path_ = Callback_.memoize do
    BS_.lib_.system.defaults.bin_pathname.
      join( 'tmx-beauty-salon search-and-r' ).to_path
  end

  NEWLINE_ = BS_::NEWLINE_

  Subject_ = -> do
    BS_::Models_::Search_and_Replace
  end

  SLASH_ = '/'.freeze

  THREE_LINES_FILE_ = 'three-lines.txt'.freeze

end

module Skylab::BeautySalon::TestSupport::Models

  S_and_R = Search_and_Replace

end
