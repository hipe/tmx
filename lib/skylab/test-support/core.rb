
class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent

    ::Skylab::TestSupport.lib_.basic::String.mutate_by_unindenting self
    self
  end
end

require_relative '../callback/core'

module Skylab::TestSupport  # :[#021].

  class << self

    def constant i
      self::Constants__.const_get i, false
    end

    def debug_IO
      self::Lib_::Stderr[]
    end

    define_method :fancy_lookup, -> do

      build_curry = -> do
        Home_.lib_.plugin::Bundle::Fancy_lookup.new_with(
          :stemname_filter, /_spec\z/,
        ).freeze
      end
      curry = nil

      -> sym, ts_mod do

        curry ||= build_curry[]
        curry.against sym, ts_mod
      end

    end.call

    def lib_
      @lib ||= Home_::Lib_::INSTANCE
    end

    def spec_rb
      Home_::Init.spec_rb
    end

    def tmpdir
      self::Lib_::Tmpdir[]
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  DOT_DOT_ = '..'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  FILE_SEP_ = ::File::SEPARATOR
  Home_ = self
  KEEP_PARSING_ = true
  stowaway :Library_, 'lib-'
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  SPACE_ = ' '.freeze
  TEST_DIR_FILENAME_ = 'test'.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
