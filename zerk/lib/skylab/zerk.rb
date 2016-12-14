require 'skylab/common'

module Skylab::Zerk  # intro in [#001] README

  class << self

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @___lib ||= Common_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  module CLI_

    class Prototype_as_Classesque

      def initialize x
        @_prototype = x
      end

      def new argv, sin, sout, serr, pn_s_a
        otr = @_prototype.dup
        otr.universal_CLI_resources sin, sout, serr, pn_s_a
        otr.argv = argv
        otr.finish
      end
    end

    Remote_lib = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end
  end

  # == model support

  class SimpleModel_  # EXPERIMENT import from [tab]

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize  # (a suggestion)
      yield self
      freeze
    end

    # redefine ..

    private :dup
  end

  # == functions

  Begin_fuzzy_retrieve_ = -> & any_oes_p do
    Home_.lib_.brazen::Collection::Common_fuzzy_retrieve.new( & any_oes_p )
  end

  Is_listy_ = -> sym do  # assume Field_
    if sym
      Field_::Can_be_more_than_zero[ sym ]
    else
      false  # the default is not listy
    end
  end

  Node_ticket_4_category_ = -> nt do  # might become :[#ac-034]. :#spot-5

    if :operation == nt.node_ticket_category
      :operation
    else
      nt.association.model_classifications.category_symbol
    end
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p  # on stack to move up
  end

  # == requirers

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.ACS
    NIL_
  end

  Require_fields_lib_ = Lazy_.call do
    Field_ = Home_.lib_.fields
    NIL_
  end

  # == orphanic stowaways

  Autoloader_ = Common_::Autoloader

  module Invocation_
    Autoloader_[ self ]
    Here_ = self
  end

  # == canonic

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Open_3 = stdlib[ :Open3 ]

    Stdlib_option_parser = Lazy_.call do
      require 'optparse'
      ::OptionParser
    end

    String_scanner = Lazy_.call do
      require 'strscan'
      ::StringScanner
    end

    system_lib = sidesys[ :System ]
    System = -> do
      system_lib[].services
    end

    Tabular = sidesys[ :Tabular ]
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  FINISHED_ = nil
  GENERIC_ERROR_EXITSTATUS = 5
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  SUCCESS_EXITSTATUS = 0
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'
  UNRELIABLE_ = :_unreliable_  # if you're evaluating this, you shouldn't be
end
