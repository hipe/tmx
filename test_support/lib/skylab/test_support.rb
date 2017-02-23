
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
        Home_.lib_.plugin::Bundle::Fancy_lookup.with(
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

  Expect_these_lines_in_array = -> act_s_a, p, tc do

    Home_::Expect_Line::Expect_these_lines_in_array[ act_s_a, p, tc ]
  end

  # --

  module THE_EMPTY_EXPRESSION_AGENT ; class << self
    alias_method :calculate, :instance_exec
  end ; end

  # --

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  DANGEROUS_MEMOIZE = -> m, & p do  # see discussion at [#042]
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

  # --

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  CLI_ = Lazy_.call do
    Zerk_lib_[]::CLI
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

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Zerk_lib_ = Lazy_.call do
    x = Home_.lib_.zerk
    Zerk_ = x  # for those who know
    x
  end

  # --

  Autoloader_ = Common_::Autoloader

  module Library_

    stdlib = Autoloader_.method :require_stdlib
    gemlib = stdlib

    o = { }

    o[ :Adsf ] = gemlib
    o[ :Benchmark ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Rack ] = gemlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    def self.const_missing c
      const_set c, H___.fetch( c )[ c ]
    end
    H___ = o.freeze

    def self.touch * i_a
      i_a.each do |i|
        const_get i, false
      end ; nil
    end
  end

  # --

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc,
    )

    Match_test_dir_proc = -> do
      mtdp = nil
      -> do
        mtdp ||= Home_.constant( :TEST_DIR_NAME_A ).method( :include? )
      end
    end.call

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Git = sidesys[ :Git ]
    Human = sidesys[ :Human ]
    Parse = sidesys[ :Parse ]  # only for 1 tree runner plugin (greenlist)
    Permute = sidesys[ :Permute ]
    Plugin = sidesys[ :Plugin ]
    Stderr = -> { ::STDERR }  # [#001.E]: why access system resources this way
    Stdout = -> { ::STDOUT }
    Open3 = stdlib[ :Open3 ]
    System_lib = sidesys[ :System ]
    Tabular = sidesys[ :Tabular ]
    Task = sidesys[ :Task ]
    TMX = sidesys[ :TMX ]
    Zerk = sidesys[ :Zerk ]
  end

  # --

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
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
