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

    # -- expectation support

    # -- set-up

    # ~ test-time configuration of the test-time environment

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

    def want_neutral_event_ sym

      # legacy [br] (somehow, somewhere) "upgrades" an expression to an
      # event, and in so doing **changes the signature** from what was
      # emitted. whatever its justification was for doing that then
      # (probably trying to ease the burden for its main modality adaptation
      # of expressing emissions), we now see this as an unacceptable amount
      # of indirection: especially when testing API, the emission signatures
      # we code for in our expectations must correspond exactly to those
      # that are emitted, otherwise there's really no point in testing our
      # API at all.
      #
      # (and it is the job of the modality adaptation layer (and no where
      # else) to adapt the emissions as-received from the API.)
      #
      # anyway, because of this legacy design, when weening off [br] the
      # the signatures of our emissions change even when our application
      # code remains the same change, an so tests break. :#history-A.1

      want_neutral_event_or_expression sym
    end

    attr_accessor :do_debug

    def debug!
      self.do_debug = true  # here we don't trigger anything but elsewhere ..
    end

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # --

  Want_Event = -> tcc do

    Common_.test_support::Want_Emission[ tcc ]
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
    FALSE = false
  NOTHING_ = nil
  TS_ = self
  UNDERSCORE_ = '_'
  Zerk_lib_ = Home_::Zerk_lib_
end
# #history-A.1: [br] used to do someting whacky changing expressions to events. no longer
