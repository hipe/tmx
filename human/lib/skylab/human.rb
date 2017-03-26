require 'skylab/common'

module Skylab::Human  # :[#001].

  class << self

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Common_ = ::Skylab::Common

  Lazy_ = Common_::Lazy

  # == proc-like support methods

  atrs = attrs = nil

  Attributes_actor_ = -> cls, * a do
    ( atrs || attrs[] )::Actor.via cls, a
  end

  Attributes_ = -> h do
    ( atrs || attrs[] )[ h ]
  end

  attrs = -> do
    Require_fields_lib_[]
    atrs
  end

  Require_fields_lib_ = Lazy_.call do
    attrs = nil
    Field_ = Home_.lib_.fields
    atrs = Field_::Attributes
    NIL_
  end

  Ucfirst_ = -> s do
    "#{ s[ 0, 1 ].upcase }#{ s[ 1 .. -1 ] }"
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  # == stowaways

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  # ==

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    gemlib = stdlib

    String_scanner = -> s do
      require 'strscan'
      ::StringScanner.new s
    end

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Levenshtein = gemlib[ :Levenshtein ]
    Parse = sidesys[ :Parse ]
    Plugin = sidesys[ :Plugin ]
    System_lib = sidesys[ :System ]
    Task = sidesys[ :Task ]
  end

  # --

  ACHIEVED_ = true
  CLI = nil  # for host
  DASH_ = '-'
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NEWLINE_ = "\n"
  NOTHING_ = nil
  NIL_ = nil
  NONE_ = nil
  KEEP_PARSING_ = true
  SPACE_ = ' '
  UNDERSCORE_ = '_'

  def self.describe_into_under y, _
    y << "rudimentary but good enough NLP hacks for textual language production"
  end
end
