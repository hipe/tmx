require 'skylab/search_and_replace'
require 'skylab/test_support'

module Skylab::SearchAndReplace::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include self
    end

    cache = {}
    define_method :lib_ do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Callback_ = ::Skylab::Callback
  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # -

    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end

  # -

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- setup

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
      TS_::Fixture_Trees
    end

    # -- hook-ins/outs

    # ~ [ca] "expect event"

    def subject_API

      Subject_module_[]::API
    end

    # ~ [br] "expect interactive"

    define_method :interactive_bin_path, ( Callback_::Lazy.call do
      self._REDO
      ::File.join TS_._MY_BIN_PATH, 'tmx-beauty-salon search-and-r'
    end )

    # -- support

    define_method :unindent_, -> do
      rx = %r(^[ ]+)
      -> s do
        s.gsub! rx, EMPTY_S_
        s
      end
    end.call

    Subject_module_ = -> do
      Home_
    end
  # -

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]
  Home_ = ::Skylab::SearchAndReplace

  EMPTY_S_ = ''
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  TS_ = self
end
