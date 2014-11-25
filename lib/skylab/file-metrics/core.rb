require_relative '..'
require 'skylab/callback/core'

module Skylab::FileMetrics

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  module Library_  # :+[#su-001]

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

  def self._lib
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_

    memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    CLI_lipstick = -> *a do
      Face__[]::CLI::Lipstick.new( * a )
    end

    DSL_DSL_enhance_module = -> x, p do
      MH__[]::DSL_DSL.enhance_module x, & p
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

    Formal_box_class = -> do
      MH__[]::Formal::Box
    end

    HL__ = sidesys[ :Headless ]

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
    end

    Let = -> do
      MH__[]::Let
    end

    MH__ = sidesys[ :MetaHell ]

    NLP_EN__ = memo[ -> do
      HL__[]::NLP::EN
    end ]

    Open_box = -> do
      MH__[]::Formal::Box.open_box.new
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Nice_proxy = -> * a do
      MH__[]::Proxy.nice.via_arglist a
    end

    Reverse_string_scanner = -> s do
      Bsc__[]::String.line_stream.reverse s
    end

    Select = -> do
      HL__[]::IO.select.new
    end

    Shellescape_path = memo[ -> do
      rx = /[ $']/
      -> x do
        rx =~ x ? Library_::Shellwords.shellescape( x ) : x
      end
    end ]

    System = -> do
      HL__[].system
    end

    System_open2 = -> mod do
      mod.include Face__[]::Open2
    end
  end

  FM_ = self

  LIB_ = FM_._lib

  Face_ = LIB_.face_top

  MONADIC_TRUTH_ = -> _ { true }

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
