require 'skylab/common'

module Skylab::Permute

  module API ; class << self
    def call * x_a, & oes_p
      Zerk_lib_[]::API.call x_a, AutonomousComponentSystem___.__instance do oes_p end
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

  class AutonomousComponentSystem___

    class << self
      def __instance
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

    def __value_name_pairs__component_association

      yield :is_plural_of, :value_name_pair
    end

    def __value_name_pair__component_association

      yield :is_singular_of, :value_name_pairs

      -> st do
        Common_::Known_Known[ st.gets_one ]
      end
    end

    def execute  # cannot fail

      x = remove_instance_variable :@value_name_pairs
      _st = if x.respond_to? :gets  # not even covered
        x  # not even covered
      else
        Common_::Stream.via_nonsparse_array x
      end

      Home_::Magnetics::TupleStream_via_PairStream[ _st ]
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
    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  KEEP_PARSING_ = true
  NIL_ = nil
  NOTHING_ = nil
  Home_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
