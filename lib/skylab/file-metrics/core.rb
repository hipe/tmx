require_relative '..'
require 'skylab/callback/core'

module Skylab::FileMetrics

  class << self

    def application_kernel_
      @___kr ||= FM_.lib_.brazen::Kernel.new FM_
    end

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Brazen = sidesys[ :Brazen ]

    Bsc__ = sidesys[ :Basic ]

    DSL_DSL_enhance_module = -> x, p do
      Parse_lib__[]::DSL_DSL.enhance_module x, & p
    end

    EN_agent = -> do
      HL__[].expression_agent.NLP_EN_agent
    end

    Face_top = Face__ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    Human = sidesys[ :Human ]

    Open_3 = stdlib[ :Open3 ]

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

    Shellwords = stdlib[ :Shellwords ]

    sketchy_rx = /[ $']/
    Shellescape_path = -> x do
      if sketchy_rx =~ x
        Shellwords[].shellescape x
      else
        x
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

  ACHIEVED_ = true
  EMPTY_S_ = ''.freeze
  FM_ = self
  IDENTITY_ = -> x { x }
  LIB_ = FM_.lib_
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
  MONADIC_TRUTH_ = -> _ { true }
  NIL_ = nil
  SPACE_ = ' '.freeze
  THE_EMPTY_MODULE_ = ::Module.new
  UNABLE_ = false

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end
