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

  # ==

  module CLI

  end

  module API

  end

  Call_ACS_ = -> x_a, acs, & pp do

    Require_zerk_[]
    Zerk_::API.call x_a, acs, & pp
  end

  class Root_Autonomous_Component_System_

    def __ping__component_operation

      -> & oes_p do

        oes_p.call :payload, :expression, :ping do |y|
          y << "ping #{ highlight '!' }"
        end

        :_hello_from_doc_test_
      end
    end
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk
  end

  # ==

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

  Autoloader_ = Common_::Autoloader

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
    Zerk = sidesys[ :Zerk ]
  end

  # --

  module OutputAdapters_
    Autoloader_[ self ]
  end

  module Models_
    Autoloader_[ self ]
  end

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
# #tombstone: dedicated API file
# #temporary-tombstone:A: old [br] API call boilerplate
