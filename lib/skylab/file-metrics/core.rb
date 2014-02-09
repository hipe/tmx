require_relative '../callback/core'

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

  module Lib_

    memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    Add_methods_for_the_procs_in_the_ivars = -> mod, * i_a do
      MetaHell__[]::Function mod, * i_a
    end

    Basic__ = sidesys[ :Basic ]

    CLI_lipstick = -> *a do
      Face__[]::CLI::Lipstick.new( * a )
    end

    DSL_DSL_enhance_module = -> x, p do
      MetaHell__[]::DSL_DSL.enhance_module x, & p
    end

    EN_conjuction_phrase = -> a do
      NLP_EN__[]::POS::Conjunction_::Phrase_.new( * a )
    end

    EN_inflect_proc = -> do
      NLP_EN__[]::Minitesimal::FUN.inflect
    end

    EN_number = -> x do
      NLP_EN__[]::Number::FUN.number[ x ]
    end

    EN_verb_phrase = -> h do
      NLP_EN__[]::Verb::Phrase.new h
    end

    Face_top = Face__ = sidesys[ :Face ]

    Formal_box_class = -> do
      MetaHell__[]::Formal::Box
    end

    Headless__ = sidesys[ :Headless ]

    Let = -> do
      MetaHell__[]::Let
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Nice_proxy = -> * a do
      MetaHell__[]::Proxy::Nice.from_i_a_and_p a, nil
    end

    NLP_EN__ = memo[ -> do
      Headless__[]::NLP::EN
    end ]

    Open_box = -> do
      MetaHell__[]::Formal::Box::Open.new
    end

    Reverse_string_scanner = -> s do
      Basic__[]::List::Scanner::For::String::Reverse[ s ]
    end

    Select = -> do
      Headless__[]::IO::Upstream::Select.new
    end

    Shellescape_path = memo[ -> do
      rx = /[ $']/
      -> x do
        rx =~ x ? Library_::Shellwords.shellescape( x ) : x
      end
    end ]

    System_open2 = -> mod do
      mod.include Face__[]::Open2
    end

    Unstyle_styled = -> x do
      Headless__[]::CLI::Pen::FUN.unstyle_styled[ x ]
    end

  end

  Face_ = Lib_::Face_top[]

  FileMetrics = self

  MONADIC_TRUTH_ = -> _ { true }

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
