require 'skylab/common'

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

        ft = ke.reactive_tree_seed.entry_tree
        ft || Home_._COVER_ME

        _head = nf.as_slug
        _sm = ft.value_state_machine_via_head _head
        if _sm
          _const = nf.as_camelcase_const_string
          ke.reactive_tree_seed.const_get _const, false
        end
      end

      ke
    end

    def describe_into_under y, _expag
      y << "gathers and presents statistics about source lines of code & more"
    end

    def lib_
      @___lib ||= Common_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  # ==

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # == small magnets

  Tailerer_via_separator_ = -> sep do

    # a "tail" is the second half of a string (e.g path) split meaningfully
    # in two. a "tailer" is a function that produces tails. so a "tailerer"..

    # this is a supertreatment of [ba]::Pathname::Localizer

    -> head do
      head_len = head.length
      head_plus_sep = "#{ head }#{ sep }"
      head_plus_sep_len = head_plus_sep.length
      r = head_plus_sep_len .. -1

      -> s, & els do
        len = s.length
        case head_len <=> len
        when -1
          if head_plus_sep == s[ 0, head_plus_sep_len ]
            s[ r ]
          else
            els[]
          end
        when 0
          if head == s
            EMPTY_S_
          else
            els[]
          end
        else
          els[]
        end
      end
    end
  end

  # == model support

  class SimpleModel_

    class << self
      alias_method :define, :new
      undef_method :new
    end

    def initialize  # suggestion
      yield self
      freeze
    end

    private :dup
  end

  # ==

  module Models

    class MondrianAsciiChoices < SimpleModel_

      attr_accessor(
        :background_fill_glyph,
        :corner_pixel,
        :horizontal_line_pixel,
        :vertical_line_pixel,
        :pixels_wide,
        :pixels_high,
      )
    end
    Autoloader_[ self ]
  end

  module Models_

    module Path  # #anemic
      Path_tailerer = Tailerer_via_separator_[ ::File::SEPARATOR ]
    end

    # (away at #open [#010])
    Autoloader_[ self, :boxxy ]
  end

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x
    else
      x
    end
  end

  # ==

  Mondrian_ = Lazy_.call do
    require 'skylab/code_metrics/operations-/mondrian'  # 2 of 2
    ::Skylab_CodeMetrics_Operations_Mondrian_EarlyInterpreter
  end

  # ==

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Totaller_ = -> do
    Home_.lib_.basic::Tree::Totaller
  end

  Require_brazen_ = Lazy_.call do  # called only 2x
    Brazen_ = Home_.lib_.brazen ; NIL_
  end

  Require_basic_ = Lazy_.call do  # 1x
    Basic_ = Home_.lib_.basic
    NIL
  end

  Zerk_lib_ = Lazy_.call do
    mod = Home_.lib_.zerk
    Zerk_ = mod
    mod
  end

  # ==

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

    String_scanner = Common_::Lazy.call do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Task = sidesys[ :Task ]

    Test_support = sidesys[ :TestSupport ]

    Treemap = sidesys[ :Treemap ]

    Zerk = sidesys[ :Zerk ]
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CONST_SEP_ = '::'
  EMPTY_A_ = []
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  LIB_ = Home_.lib_
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n"
  NOTHING_ = nil
  NIL_ = nil
  SPACE_ = ' '.freeze
  UNABLE_ = false
end
