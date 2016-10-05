
class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent
    ::Skylab::TestSupport.lib_.basic::String.mutate_by_unindenting self
    self
  end
end

require 'skylab/common'

module Skylab::TestSupport  # :[#021].

  class << self

    def describe_into_under y, _
      y << "quickie, the tree runner, doctest (defunct), simplecov (defunct)"
    end

    def constant i
      self::Constants__.const_get i, false
    end

    def debug_IO
      self::Lib_::Stderr[]
    end

    define_method :fancy_lookup, -> do

      build_curry = -> do
        Home_.lib_.plugin::Bundle::Fancy_lookup.new_with(
          :entry_group_head_filter, /_spec\z/,
        ).freeze
      end
      curry = nil

      -> sym, ts_mod do

        curry ||= build_curry[]
        curry.against sym, ts_mod
      end

    end.call

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Home_::Lib_, Home_ )
    end

    def spec_rb
      Home_::Init.spec_rb
    end

    def tmpdir
      lib_.system.filesystem.tmpdir
    end
  end  # >>

  class Lazy_Constants

    # subclass and define your "constant-like" values thru instance methods.
    # call the *class* method `lookup` for value lazy-evaluated & memoized.

    class << self
      def lookup sym
        ( @___instance ||= new ).lookup sym
      end
      private :new
    end

    def initialize
      @_entries = {}
    end

    def lookup sym
      @_entries.fetch sym do
        x = send sym
        @_entries[ sym ] = x
        x
      end
    end
  end

  # -- (see discussion of "dangerous memoize" at [#042])

  DANGEROUS_MEMOIZE = -> m, & p do
    Define_dangerous_memoizer[ self, m, & p ]
  end

  MEMOIZE = -> m, & p do
    Define_memoizer___[ self, m, & p ]
  end

  module Memoization_and_subject_sharing

    def self.[] tcc
      tcc.extend self
    end

    define_method :dangerous_memoize, & DANGEROUS_MEMOIZE

    define_method :shared_subject, & DANGEROUS_MEMOIZE

    define_method :memoize, & MEMOIZE
  end

  Define_dangerous_memoizer = -> cls, m, & p do

    first = true ; x = nil

    cls.send :define_method, m do
      if first
        first = false
        x = instance_exec( & p )  # (the center of the crime of [#042])
      end
      x
    end
  end

  Define_memoizer___ = -> cls, m, & p do

    first = true ; x = nil

    cls.send :define_method, m do
      if first
        first = false
        x = p[]
      end
      x
    end
  end

  # --

  Common_ = ::Skylab::Common

  Lazy_ = Common_::Lazy

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  CLI_support_ = -> do
    Home_.lib_.brazen::CLI_Support
  end

  Path_looks_absolute_ = -> path do
    Home_.lib_.system.path_looks_absolute path
  end

  Path_looks_relative_ = -> path do
    Home_.lib_.system.path_looks_relative path
  end

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  # --

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  DASH_ = '-'.freeze
  DOT_ = '.'
  DOT_DOT_ = '..'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  FILE_SEP_ = ::File::SEPARATOR
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  stowaway :Library_, 'lib-'
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  NOTHING_ = nil
  NIL_ = nil
  stowaway :IO, 'io/spy--'
  SPACE_ = ' '.freeze
  TEST_DIR_FILENAME_ = 'test'.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
