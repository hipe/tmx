require 'skylab/common'

module Skylab::DocTest

  # (the README [#001] acts as the "top" of the documentation graph too.)

  # here is the minimal interesting example for calling the API:
  #
  #     _path = "#{ DocTest.dir_path }.rb"
  #
  #     st = DocTest::API.call(
  #       :synchronize,
  #       :asset_line_stream, open( _path ),
  #       :output_adapter, :quickie,
  #     )
  #
  #     st.gets  # => "require_relative .."
  #     NEWLINE_ == st.gets || fail
  #     # ..

  module API
    class << self
      def call * x_a, & p
        Call_ACS_.call( x_a, Root_Autonomous_Component_System_.instance_ ) {|_| p }
      end
    end  # >>
  end

  default_handler = -> * i_a, & ev_p do  # this is probably nearest to an #[#co-045], but not ideal
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

      -> & p do

        p.call :payload, :expression, :ping do |y|
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

      yield :parameter, :asset_extname, :optional,

            :parameter, :test_filename_pattern, :optional

      # #open [#ze-049] for now the above must be here and not there.

      yield :via_ACS_by, -> do
        Home_::Operations_::Recurse.new
      end
    end
  end

  class << self

      def get_output_adapter_slug_array_
        self::OutputAdapters_.entry_tree.to_stream.map_by do | et |
          et.name.as_slug
        end.to_a
      end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport, false
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  # ==

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # ==

  module Paraphernalia_

    # rather than the abstract or particular classes (and/or similar) to have
    # to represent this meta-data, we conentrate all of it here for now ..

    _IS_NODE_OF_INTEREST = {  # more or less as covered
      context_node: true,
      example_node: true,
      const_definition: false,
      shared_subject: false,
    }

    Is_node_of_interest = -> parti do
      _IS_NODE_OF_INTEREST.fetch parti.paraphernalia_category_symbol
    end

    _IS_BRANCH = {
      context_node: true,
      example_node: false,
    }

    Is_branch = -> parti do
      _IS_BRANCH.fetch parti.paraphernalia_category_symbol
    end
  end

  # == functions

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk
    ACS_ = Home_.lib_.ACS
    NIL_
  end

  Stream_ = -> nonsparse_a do
    Common_::Stream.via_nonsparse_array nonsparse_a
  end

  # ==

  module Lib_  # # use this name per [sl] viz for now

    sidesys = Autoloader_.build_require_sidesystem_proc

    _Strscn = Lazy_.call do
      require 'strscan' ; ::StringScanner
    end

    String_scanner = -> s do
      _Strscn[].new s
    end

    System = -> do
      System_lib[].services
    end

    ACS = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]
    Git = sidesys[ :Git ]
    System_lib = sidesys[ :System ]
    Test_support = sidesys[ :TestSupport ]
    Zerk = sidesys[ :Zerk ]
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  ACHIEVED_ = true
  BEFORE_ALL_ = :before_all  # will move
  BLANK_RX_ = /\A[[:space:]]*\z/
  CONST_SEP_ = '::'.freeze
  DEFAULT_TEST_DIRECTORY_ENTRY_ = 'test'
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  NEWLINE_ = "\n".freeze  # because #spot1.2
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
    FALSE = false ; TRUE = true
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  ZERO_LENGTH_LINE_RX_ = /\A$/

  def self.describe_into_under y, _
    y << "a black-box reconception of python's tool of the same name,"
    y << "infers test code from example code in comments in code files."
  end
end
# #tombstone: old self-test doc body copy
# #tombstone: dedicated API file
