require 'skylab/common'

module Skylab::DocTest
  # -
    # see [#001] (the README) for an introduction.
    # synopsis:
    #
    # these first few lines of a text span, you can write whatever you want &
    # they will not appear in the generated spec file. the last line however,
    # will appear as the description string of your context or example.
    #
    #     THIS_FILE_ = self._NO::Expect_Line::File_Shell[ __FILE__ ]
    #
    #     # this comment gets included in the output because it is indented
    #     # with four or more spaces and is part of a code span that goes out.
    #
    #
    # now that we are back under four spaces in from our local margin, this
    # is again a text span. the previous code span is treated as a before
    # block because it has no magic "# =>" predicate sequence. it becomes a
    # #todo: go this away (above)
    # before `all` block because it looks like it starts with a constant
    # assignment.
    #
    # this line here is the description for the following example
    #
    #     o = THIS_FILE_
    #
    #     o.contains( "they will not#{' '}appear" ) # => false
    #
    #     o.contains( "will appear#{' '}as the description" )  # => true
    #
    #     o.contains( "this comment#{' '}gets included" )  # => true
    #
    #     o.contains( "this line#{' '}here is the desc" )  # => true
    #
    #
    # we now strip trailing colons from these description lines:
    #
    #     THIS_FILE_.contains( 'from these description lines"' ) # => true

    module CLI
      # ..
    end

    module API

      class << self

        def call * x_a, & oes_p

          # don't ever write events to stdout/stderr by default.
          # see temporary tombstone A

          ::Kernel._K_ALSO_fix_indent_here
        end
      end  # >>
    end

  class << self

      def get_output_adapter_slug_array_
        self::OutputAdapters_.entry_tree.to_stream.map_by do | et |
          et.name.as_slug
        end.to_a
      end

    def test_support_  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport, false
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib___, self )
    end
  end  # >>

  # --

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  # --

  module Magnetics_
    Autoloader_[ self ]
  end

  # --

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  # --

  module Lib___

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]

    system_lib = nil

    System = -> do
      system_lib[].services
    end

    system_lib = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]
  end

  # --

  module OutputAdapters_
    Autoloader_[ self ]
  end

  module Models_
    Autoloader_[ self ]
  end

  # -

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  ACHIEVED_ = true
  BLANK_RX_ = /\A[[:space:]]*\z/
  CONST_SEP_ = '::'.freeze
  DocTest = :_fix_these_  # #todo
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  NEWLINE_ = "\n".freeze  # because #spot-2
  NIL_ = nil
  NOTHING_ = nil
  UNABLE_ = false
end
# #temporary-tombstone:A: old [br] API call boilerplate
