require 'skylab/common'

module Skylab::Zerk  # intro in [#001] README

  class << self

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @___lib ||= Common_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  module CLI_

    class Prototype_as_Classesque

      def initialize x
        @_prototype = x
      end

      def new argv, sin, sout, serr, pn_s_a
        otr = @_prototype.dup
        otr.universal_CLI_resources sin, sout, serr, pn_s_a
        otr.argv = argv
        otr.finish
      end
    end

    Remote_lib = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end
  end

  # == functions

  Begin_fuzzy_retrieve_ = -> & any_oes_p do
    Home_.lib_.brazen::Magnetics::Item_via_OperatorBranch::FYZZY.new( & any_oes_p )
  end

  Is_listy_ = -> sym do  # assume Field_
    if sym
      Field_::Can_be_more_than_zero[ sym ]
    else
      false  # the default is not listy
    end
  end

  Node_reference_4_category_ = -> nt do  # might become :[#ac-034]. :#spot-5

    if :operation == nt.node_reference_category
      :operation
    else
      nt.association.model_classifications.category_symbol
    end
  end

  Attributes_actor_ = -> cls, * a do
    Require_fields_lib_[]
    Field_::Attributes::Actor.via cls, a
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p  # on stack to move up
  end

  # == stowaways

  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  module API  # (description in placeholder file)
    class << self
      def call args, acs, & pp
        Require_ACS_[]
        pp ||= ACS_.handler_builder_for acs
        o = Here_::Invocation___.new args, acs, & pp
        bc = o.execute
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
    Autoloader_[ self ]
    Here_ = self
  end

  module MicroserviceToolkit  # (attempt to stitch together old and new semi-hiddenly)

    Autoloader_[ self ]

    lazily :ModelCentricOperatorBranch do
      Home_.lib_.plugin::ModelCentricOperatorBranch
    end

    lazily :Normalization do
      Home_.lib_.fields::Normalization
    end

    lazily :ParseArguments_via_FeaturesInjections do
      # a convenience alias so the remote doesn't have to know where it is
      No_deps_zerk_[]::ParseArguments_via_FeaturesInjections
    end

    lazily :API_ArgumentScanner do
      No_deps_zerk_[]::API_ArgumentScanner
    end

    lazily :NoDependenciesZerk do  # [pl]
      No_deps_zerk_[]
    end
  end

  module Invocation_
    Autoloader_[ self ]
    Here_ = self
  end

  lazily :MagneticBySimpleModel do
    No_deps_zerk_[]::MagneticBySimpleModel
  end

  lazily :SimpleModel_ do
    No_deps_zerk_[]::SimpleModel
  end

  # == requirers

  Require_brazen_ = Lazy_.call do
    Brazen_ = Home_.lib_.brazen ; nil
  end

  No_deps_zerk_ = Lazy_.call do
    require 'no-dependencies-zerk'
    ::NoDependenciesZerk
  end
  No_deps = No_deps_zerk_  # [fi], [pl]

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.ACS
    NIL_
  end

  Require_fields_lib_ = Lazy_.call do
    Field_ = Home_.lib_.fields
    NIL_
  end

  Basic_ = Lazy_.call do
    Home_.lib_.basic
  end

  # == canonic

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Stdlib_option_parser = Lazy_.call do
      require 'optparse'
      ::OptionParser
    end

    String_scanner = Lazy_.call do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Open_3 = stdlib[ :Open3 ]
    Plugin = sidesys[ :Plugin ]
    System_lib = sidesys[ :System ]
    Tabular = sidesys[ :Tabular ]
  end

  ACHIEVED_ = true
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  FINISHED_ = nil
  GENERIC_ERROR_EXITSTATUS = 5
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  SUCCESS_EXITSTATUS = 0
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'
  UNRELIABLE_ = :_unreliable_  # if you're evaluating this, you shouldn't be

  def self.describe_into_under y, _
    y << "a goofy, fun series of experiments for command-like apps"
    y << "both interactive and not."
  end
end
