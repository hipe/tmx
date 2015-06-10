require_relative '..'
require 'skylab/callback/core'

module Skylab::FileMetrics

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = {}
    o[ :FileUtils ] =
    o[ :Open3 ] =
    o[ :Shellwords ] =
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |const_i|
      if o.key? const_i
        const_set const_i, o.fetch( const_i )[ const_i ]
      else
        x = super const_i
        const_defined?( const_i, false ) or fail "scott whallan"
        x
      end
    end

    Autoloader_[ self ]
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    define_singleton_method :_memoize, Callback_::Memoize

    Brazen = sidesys[ :Brazen ]

    Bsc__ = sidesys[ :Basic ]

    DSL_DSL_enhance_module = -> x, p do
      Parse_lib__[]::DSL_DSL.enhance_module x, & p
    end

    EN_agent = -> do
      HL__[].expression_agent.NLP_EN_agent
    end

    EN_conjuction_phrase = -> a do
      NLP_EN__[]::POS::Conjunction_::Phrase_.new( * a )
    end

    EN_number = -> x do
      NLP_EN__[]::Number.number x
    end

    EN_verb_phrase = -> h do
      NLP_EN__[]::Verb::Phrase.new h
    end

    Face_top = Face__ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    Hu___ = sidesys[ :Human ]

    NLP_EN__ = _memoize do
      Hu___[]::NLP::EN
    end

    Parse_lib__ = sidesys[ :Parse ]

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Reverse_string_scanner = -> s do
      Bsc__[]::String.line_stream.reverse s
    end

    Select = -> do
      System_lib__[]::IO.select.new
    end

    Shellescape_path = _memoize do
      rx = /[ $']/
      -> x do
        rx =~ x ? Library_::Shellwords.shellescape( x ) : x
      end
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    System_open2 = -> mod do
      mod.include Face__[]::Open2
    end

    Test_support = sidesys[ :TestSupport ]
  end

  EMPTY_S_ = ''.freeze
  FM_ = self
  IDENTITY_ = -> x { x }
  LIB_ = FM_.lib_
  Face_ = LIB_.face_top
  MONADIC_TRUTH_ = -> _ { true }
  SPACE_ = ' '.freeze
  UNABLE_ = false

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end
