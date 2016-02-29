require 'skylab/callback'

module Skylab::CodeMetrics

  class << self

    def application_kernel_
      @___kr ||= ___build_kernel
    end

    def ___build_kernel

      Require_brazen_[]  # 1 of 2

      ke = Brazen_::Kernel.new Home_

      ke.fast_lookup = -> nf do

        # any time any name needs to be resolved from the top-level, try
        # to resolve it this way first so we don't have to stream over
        # several nodes, loading and binding each one (#[#br-015]A).
        # doing this allows that a lowlevel utility-like script like
        # "tally" can perhaps still work while its sibling nodes are
        # in a developmental (broken) state.

        et = ke.reactive_tree_seed.entry_tree
        # assume `et.has_directory`
        if et.has_entry_for_slug nf.as_slug
          ke.reactive_tree_seed.const_get nf.as_const, false
        end
      end

      ke
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

  Require_brazen_ = Callback_::Lazy.call do  # called only 2x
    Brazen_ = Home_.lib_.brazen ; NIL_
  end

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

    String_scanner = Callback_::Lazy.call do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]
  end

  ACHIEVED_ = true
  EMPTY_A_ = []
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  LIB_ = Home_.lib_
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = ' '.freeze
  UNABLE_ = false

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]
end
