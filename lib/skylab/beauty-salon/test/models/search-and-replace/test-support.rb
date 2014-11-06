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

    def start_session path
      @session = Session__.new( self, path ).start
      nil
    end
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
end
