module Skylab::BeautySalon::TestSupport

  module Models::Search_And_Replace

    def self.[] tcc
      TS_::Expect_Event[ tcc ]
      tcc.include self
    end

    # ~ setup

    def start_tmpdir_

      td = memoized_tmpdir_

      td.prepare

      @tmpdir = td.new_with(
        :path, td.join( 'haha-dir' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )
      nil
    end

    def to_tmpdir_add_wazoozle_file_

      @tmpdir.write 'ok-whatever-wazoozle.txt', unindent_( <<-O )
        ok oh my geez --> HAHA <--
      O

      NIL_
    end

    def my_fixture_file_ entry_s
      my_fixture_files_[ entry_s ]
    end

    def my_fixture_files_
      Models::Search_And_Replace::Fixture_Trees
    end

    # ~ hook-ins/outs

    ## ~~ [ca] "expect event"

    def subject_API  # CHANGE IT from top

      TS_::Models::Search_And_Replace::Subject_module_[]::API
    end

    ## ~~ [br] "expect interactive"

    define_method :interactive_bin_path, ( Callback_.memoize do

      ::File.join TS_._MY_BIN_PATH, 'tmx-beauty-salon search-and-r'

    end )

    # ~ support for support

    Subject_module_ = -> do
      Home_::Models_::Search_and_Replace
    end

    UNINDENT_ = -> do
      rx = %r(^[ ]+)
      -> s do
        s.gsub! rx, EMPTY_S_
        s
      end
    end.call

    define_method :unindent_, UNINDENT_

  end
end
