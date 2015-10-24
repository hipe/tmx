require 'skylab/callback'

module Skylab::FileMetrics

  class << self

    def application_kernel_
      @___kr ||= Home_.lib_.brazen::Kernel.new Home_
    end

    def describe_into_under y, _expag
      y << "gathers and presents statistics about source lines of code & more"
    end

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Totaller_ = -> do
    Home_.lib_.basic::Tree::Totaller
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Brazen = sidesys[ :Brazen ]

    Basic = sidesys[ :Basic ]

    DSL_DSL_enhance_module = -> x, p do
      Parse[]::DSL_DSL.enhance_module x, & p
    end

    Human = sidesys[ :Human ]

    Open_3 = stdlib[ :Open3 ]

    Parse = sidesys[ :Parse ]

    Reverse_string_scanner = -> s do
      Basic[]::String.line_stream.reverse s
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

    Test_support = sidesys[ :TestSupport ]
  end

  ACHIEVED_ = true
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  LIB_ = Home_.lib_
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
  MONADIC_TRUTH_ = -> _ { true }
  NIL_ = nil
  SPACE_ = ' '.freeze
  UNABLE_ = false

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

end
