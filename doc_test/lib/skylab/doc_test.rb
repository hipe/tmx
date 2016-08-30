require 'skylab/common'

module Skylab::DocTest

  # (the README [#001] acts as the "top" of the documentation graph too.)

  # here is the minimal interesting example for calling the API:
  #
  #     _path = "#{ DocTest.dir_pathname.to_path }.rb"
  #
  #     st = DocTest::API.call(
  #       :synchronize,
  #       :asset_line_stream, open( _path ),
  #       :output_adapter, :quickie,
  #     )
  #
  #     st.gets  # => "require_relative .."
  #     st.gets  # blank line..
  #     # ..

  module API
    class << self
      def call * x_a, & oes_p
        Call_ACS_.call( x_a, Root_Autonomous_Component_System_.instance_ ) {|_| oes_p }
      end
    end  # >>
  end

  default_handler = -> * i_a, & ev_p do  # #[#co-045]
    if :error == i_a.first
      if :expression == i_a[1]
        raise ev_p[ "" ]  # eew
      else
        _ = ev_p[]
        _ev = _.to_exception
        raise _ev
      end
    end
  end

  default_handler_builder = -> _root_ACS do
    default_handler
  end

  Call_ACS_ = -> x_a, acs, & pp do
    pp ||= default_handler_builder
    Require_zerk_[]
    Zerk_::API.call x_a, acs, & pp
  end

  class Root_Autonomous_Component_System_

    class << self

      def instance_
        @__instance ||= new
      end

      alias_method :new_instance__, :new  # while we're in denial

      private :new
    end  # >>

    def __ping__component_operation

      yield :description, -> y { y << "just a simple ping." }

      -> & oes_p do

        oes_p.call :payload, :expression, :ping do |y|
          y << "pong from doc-test#{ highlight '!' }"
        end

        nil
      end
    end

    def __synchronize__component_operation
      Home_::Operations_::Synchronize
    end

    def __recurse__component_operation

      yield :parameter, :list, :optional, :is_flag

      yield :via_ACS_by, -> do
        _fs = Home_.lib_.system.filesystem
        Home_::Operations_::Recurse.new _fs
      end
    end
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk
    ACS_ = Home_.lib_.ACS
    NIL_
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

  module RecursionMagnetics_
    Autoloader_[ self ]
  end

  module Magnetics_
    Autoloader_[ self ]
  end

  # --

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  # --

  module Lib___

    sidesys = Autoloader_.build_require_sidesystem_proc

    ACS = sidesys[ :Autonomous_Component_System ]
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

  module RecursionModels_
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
# #tombstone: old self-test doc body copy
# #tombstone: dedicated API file
