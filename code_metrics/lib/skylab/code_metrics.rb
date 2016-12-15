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

  # ==

  module Models_

    class Mondrian
      # ==begin temporary mess for [br]
      Actions = nil
      def self.adapter_class_for _modality_symbol
        self
      end
      def initialize _self_class, _upper_bnd
        NOTHING_
      end
      def bound_call_under cli
        o = cli.resources
        _op = Home_::Operations_::Mondrian::CLI.new(
          o.argv, o.sin, o.sout, o.serr, o.invocation_string_array,
          cli.method( :maybe_use_exit_status ),
        )
        _op.to_bound_call_of_operator
      end
      def expression_agent
        self
      end
      alias_method :calculate, :instance_exec
      def plural_noun s
        "#{ s }s"
      end
      # ==end temporary mess for [br]
    end
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

  Lazy_ = Common_::Lazy

  Totaller_ = -> do
    Home_.lib_.basic::Tree::Totaller
  end

  Require_brazen_ = Lazy_.call do  # called only 2x
    Brazen_ = Home_.lib_.brazen ; NIL_
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

    Test_support = sidesys[ :TestSupport ]

    Zerk = sidesys[ :Zerk ]
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
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
