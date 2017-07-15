
# kind of nasty - besides the block of code associated with this comment,
# this file is an otherwise straightforward and ordinary "test support"
# file. like perhaps all other files like this, this file calls quickie's
#
#   `enhance_test_support_module_with_the_method_called_describe`
#
# , which (if rspec is running) effectively does nothing, but if quickie
# is running it gives us the implicit assertion that we are not running any
# tests outside of our sandbox module dedicated to tests, which is something
# we care about.
#
# now, the only issue with that is if we are trying to generate a coverage
# report *of* quickie. if this is the case, then we need the coverage system
# "turned on" *before* quickie itself loads.
#
# we can generalize this concern to say maybe
# this is why THIS:

module Skylab
  module TestSupport
    module TestSupport
      module CoverageFunctions___ ; class << self

        # (this is whipped together just to get coverage for the quickie
        # root file. see [#xxx] and [#yyy] for the "proper" way turn on
        # coverage #todo)

        def __maybe_begin_coverage_
          s = ::ENV[ 'COVER' ]
          if s
            if s =~ /\A(?:y(?:es)?|t(?:r(?:u(:?e)?)?)?)\z/i
              _do_cover
            elsif s =~ /\A(?:no|false)\z/i
              NOTHING_  # hi.
            else
              fail "say 'true' or 'false' for COVER environment variable (had: #{ s.inspect })"
            end
          end
        end

        def _do_cover

          # to tell simpelcov what the root of our "project" (of interest) is,
          # we need the proper gem path (with all the cruft in front of it)
          # so we can't (under our normal development environment) get to it
          # from __FILE__ which normally is a "real" filesystem path and not
          # the heavily symlinked path used in our development gem installations.
          # that is, even though this file and the sidsystem root file are
          # nearby in real life, the latter "thinks" it is in the gem
          # directory, and we can't otherwise easily infer what that directory
          # is without first loading the latter gem.
          #
          # depending on what you're trying to cover, the above will give you
          # variously more or less pain. since we're trying to cover quickie
          # (and not the toplevel [ts] asset node, and not, say [co] toplevel
          # node), life is easier because toplevel sidesystem nodes "know"
          # their "crufty" path.

          _gem_dir_path = Home_.dir_path

          require 'simplecov'

          decide = -> path do
            if 'quickie.rb' == ::File.basename( path )
              false
            else
              $stderr.puts "(STRANGE PATH: #{ path })"
              true
            end
          end

          cache = {}
          ::SimpleCov.start do
            add_filter do |source_file|
              path = source_file.filename
              cache.fetch path do
                do_filter_out = decide[ path ]
                cache[ path ] = do_filter_out
              end
            end
            root _gem_dir_path
          end

          NIL
        end

      end ; end
    end
  end
end

require 'skylab/test_support'

module Skylab::TestSupport::TestSupport

  class << self

    def [] tcc

      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods
    end

    def doc_path_ s
      @___doc_path ||= ::File.join( _sidesystem_path, 'doc' )
      ::File.join @___doc_path, s
    end

    def noent_path_
      @___noent_path ||= ::File.join( Home_.dir_path, 'noent.file' )
    end

    def test_path_ s
      @___test_path ||= ::File.join( _sidesystem_path, 'test' )
      ::File.join @___test_path, s
    end

    def _sidesystem_path
      @___ssp ||= ::File.expand_path '../../..', Home_.dir_path
    end

    cache = {}
    define_method :lib_ do |sym|
      cache.fetch sym do
        x = Home_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  CoverageFunctions___.__maybe_begin_coverage_  # see
  Home_ = ::Skylab::TestSupport
  Home_::Quickie.enhance_test_support_module_with_the_method_called_describe self

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  module InstanceMethods

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def fixture_file__ filename
      ::File.join Home_::Fixtures.files_path, filename
    end

    ftcache = {}
    define_method :fixture_tree do |sym, * s_a|
      path = ftcache.fetch sym do
        x = Home_::Fixtures.tree sym
        ftcache[ sym ] = x
        x
      end
      if s_a.length.zero?
        path
      else
        ::File.join path, * s_a
      end
    end

    def subject_API_value_of_failure
      FALSE
    end

    # --

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      @debug_IO ||= Home_.lib_.stderr
    end
  end

  # --

  Expect_Emission_Fail_Early = -> tcc do
    Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
  end

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    Home_::Memoization_and_subject_sharing[ tcc ]
  end

  Non_Interactive_CLI_Fail_Early = -> tcc do
    Zerk_test_support_[]::Non_Interactive_CLI::Fail_Early[ tcc ]
  end

  The_Method_Called_Let = -> tcc do
    Home_::Let[ tcc ]
  end

  # --

  Zerk_test_support_ = -> do
    Home_.lib_.zerk.test_support
  end

  # --

  Common_ = Home_::Common_
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  DASH_ = Home_::DASH_
  EMPTY_A_ = Common_::EMPTY_A_
  EMPTY_S_ = Common_::EMPTY_S_
  Lazy_ = Common_::Lazy
  NIL = nil  # open [#sli-016.C]
    FALSE = false ; TRUE = true
  NOTHING_ = nil
  TS_ = self
  UNABLE_ = false
  UNDERSCORE_ = Home_::UNDERSCORE_
end
# :+tombstone: 'mock_FS' as bundle
