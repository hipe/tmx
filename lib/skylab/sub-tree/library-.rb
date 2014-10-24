module Skylab::SubTree

  module Library_  # :+[#su-001]

    stdlib = Autoloader_.method :require_stdlib
    o = { }
    o[ :FileUtils ] =
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set  ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end

    def self.touch i
      const_defined?( i, false ) or const_get( i, false ) ; nil
    end
  end

  module Lib_

    memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    API_Params = -> * x_a do
      Face__[]::API::Params_.via_iambic x_a
    end

    Bsc__ = sidesys[ :Basic ]

    Basic_fields = -> * x_a do
      if x_a.length.zero?
        MH__[]::Basic_Fields
      else
        MH__[]::Basic_Fields.via_iambic x_a
      end
    end

    Bound_field_reflection_class = -> do
      Bsc__[]::Field.reflection.bound
    end

    Box = -> do
      Bsc__[]::Box.new
    end

    Box_class = -> do
      Bsc__[]::Box
    end

    Bzn__ = sidesys[ :Brazen ]

    Clear_pwd_cache = -> do
      System[].filesystem.path_tools.clear
    end

    CLI_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    CLI_lipstick = -> * x_a do
      Face__[]::CLI.lipstick.new( * x_a )
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.via_iambic x_a
    end

    Properties_stack_frame = -> * a do
      Bzn__[].properties_stack.common_frame.via_arglist a
    end

    Distill_proc = -> do
      Callback_.distill
    end

    EN_add_methods = -> * i_a do
      HL__[].expression_agent.NLP_EN_methods.via_arglist i_a
    end

    Enhance_as_API_normalizer = -> x, * x_a do
      Face__[]::API::Normalizer_.enhance_client_class x, * x_a
    end

    Entity = -> * a do
      Bzn__[]::Entity.via_arglist a
    end

    Entity_via_iambic = -> x_a do
      client = x_a.fetch 0
      :fields == x_a.fetch( 1 ) or raise ::ArgumentError
      x_a[ 0, 2 ] = EMPTY_A__
      Basic_fields[ :client, client,
        :absorber, :initialize,
        :field_i_a, x_a ]
    end
    EMPTY_A__ = [].freeze  # etc

    Face__ = sidesys[ :Face ]

    Field_front_expression_agent = -> a, b do
      Face__[]::API::Normalizer_::Field_Front_Exp_Ag_.new a, b
    end

    Fields_from_methods = -> *a, p do
      MH__[]::Fields::From.methods.iambic_and_block a, p
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    Funcy_globless = -> x do
      MH__[].funcy_globless x
    end

    Hack_label_proc = -> do
      Face__[]::API::Normalizer_::Hack_label
    end

    HL__ = sidesys[ :Headless ]

    Iambic = -> * x_a do
      Face__[]::Iambic.via_iambic x_a
    end

    InformationTactics__ = sidesys[ :InformationTactics ]

    MH__ = sidesys[ :MetaHell ]

    Method_lib = -> do
      Bsc__[]::Method
    end

    NLP_EN_lib = -> do
      HL__[]::NLP::EN
    end

    Order_proxy = -> x do
      Bsc__[]::Hash::Order_Proxy.new x
    end

    Porcelain__ = sidesys[ :Porcelain ]

    Power_Scanner = -> * x_a do
      Callback_::Scn.multi_step.build_via_iambic x_a
    end

    Pretty_path_proc = -> do
      System[].filesystem.path_tools.pretty_path
    end

    Spec_rb = -> do
      TestSupport__[].spec_rb
    end

    Stock_API_expression_agent = -> do
      Face__[]::CLI::Client::API_Integration_::EXPRESSION_AGENT_
    end

    Strange_proc = -> do
      MH__[].strange.to_proc
    end

    Struct = -> * i_a do
      Bsc__[]::Struct.make_via_arglist i_a
    end

    Summarize_time = -> x do
      InformationTactics__[]::Summarize::Time[ x ]
    end

    System = -> do
      HL__[].system
    end

    Test_dir_name_a = -> do
      TestSupport__[].constant :TEST_DIR_NAME_A
    end

    TestSupport__ = sidesys[ :TestSupport ]

    Touch_const_reader = -> * a do
      MH__[].touch_const_reader( * a )
    end

    Treelib__ = memo[ -> do
      Porcelain__[]::Tree
    end ]

    Write_isomorphic_option_parser_options = -> * a do
      Face__[]::CLI::Client::API_Integration_::OP_.new( * a ).execute
    end
  end
end
