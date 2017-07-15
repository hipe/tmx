require 'skylab/common'

module Skylab::Permute

  module API ; class << self
    def call * x_a, & oes_p
      Zerk_lib_[]::API.call x_a, AutonomousComponentSystem_.instance_ do oes_p end
    end
  end ; end

  class << self

    def describe_into_under y, _
      y << "display permutations. sort of a stalking horse frontier prorotype"
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  class AutonomousComponentSystem_

    class << self
      def instance_
        @___instance ||= new
      end
      private :new
    end  # >>

    def __ping__component_operation

      yield :description, -> y { y << "(ping the backend)" }

      -> & oes_p do
        oes_p.call :info, :expression, :ping do |y|
          y << "hello from permute."  # for [tmx]
        end
        NOTHING_
      end
    end

    def __generate__component_operation

      yield :via_ACS_by, -> do
        Generate_Operation___.new
      end
    end
  end

  # ==

  class Generate_Operation___

    class << self
      def describe_into_under y, expag
        y << "given a collection of \"categories\" where each category is"
        y << "one name and one or more values, produce a \"stream of tuples\""
        y << "(rows of data) representing all the possible permutations"
        y << "combining one value from every category."
      end
    end  # >>

    def __value_name_pairs__component_association

      yield :is_plural_of, :value_name_pair
    end

    def __value_name_pair__component_association

      yield :is_singular_of, :value_name_pairs

      yield :description, -> y do
        y << "never see this (because custom) yadda yadda"
      end

      -> st do
        x = st.gets_one
        Common_::KnownKnown[ x ]
      end
    end

    def execute  # cannot fail

      _x = remove_instance_variable :@value_name_pairs

      _st = Common_::Stream.via_nonsparse_array _x

      Home_::Magnetics::TupleStream_via_ValueNameStream[ _st ]
    end
  end

  # ==

  Common_ = ::Skylab::Common

  Lazy_ = Common_::Lazy

  Zerk_lib_ = Lazy_.call do
    Home_.lib_.zerk
  end

  Autoloader_ = Common_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]  # Collection.fuzzy etc
    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  EMPTY_A_ = []
  KEEP_PARSING_ = true
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = nil
  Home_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
