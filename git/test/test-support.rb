require 'skylab/git'
require 'skylab/test_support'

module Skylab::Git::TestSupport

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end
  end  # >>

  Common_ = ::Skylab::Common

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -
    cache = {}
    Use_method___ = -> sym do

      _test_support_lib = cache.fetch sym do

        const = Common_::Name.via_variegated_symbol( sym ).as_const

        x = if TS_.const_defined? const
          TS_.const_get const
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        cache[ sym ] = x
        x
      end

      _test_support_lib[ self ]
    end
  # -

  module InstanceMethods___

    # ~ test-time support

    # ~ ~ time-time configuration of the test-time environment

    attr_accessor :do_debug

    def debug!
      self.do_debug = true  # here we don't trigger anything but elsewhere ..
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :memoized_tmpdir_, -> do

      o = nil
      -> do
        if o
          o.for self
        else
          o = Home_.lib_.system_lib::Filesystem::Tmpdir.memoizer_for self, 'git-xyzizzy'
          o.instance
        end
      end
    end.call

    def tmpdir_path_for_memoized_tmpdir
      real_filesystem_.tmpdir_path
    end

    def real_filesystem_
      Home_.lib_.system.filesystem
    end

    def dirs_in_ path
      Common_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type d -mindepth 1`.split NEWLINE_ )
    end

    def files_in_ path
      Common_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type f`.split NEWLINE_ )
    end

    def subject_API_value_of_failure
      FALSE
    end

    def subject_API
      Home_::API
    end

    def expect_neutral_event_ sym

      em = expect_neutral_event
      sym.should eql em.cached_event_value.to_event.terminal_channel_symbol
      em
    end
  end

  # --

  Expect_Event = -> tcc do

    Common_.test_support::Expect_Emission[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Lazy_ = Common_::Lazy

  Fixture_data_path_ = Lazy_.call do
    ::File.join TS_.dir_path, 'fixture-data'
  end

  Fixture_tree_ = -> sym do
    ::File.join Fixture_trees_[], sym.to_s.gsub( UNDERSCORE_, DASH_ )
  end

  Fixture_trees_ = Lazy_.call do
    ::File.join TS_.dir_path, 'fixture-trees'
  end

  # --

  Home_ = ::Skylab::Git

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  DASH_ = '-'
  DOT_ = '.'
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  TS_ = self
  UNDERSCORE_ = '_'
  Zerk_lib_ = Home_::Zerk_lib_
end
