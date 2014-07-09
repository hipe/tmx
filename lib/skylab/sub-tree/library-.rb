module Skylab::SubTree

  module Library_  # :+[#su-001]

    stdlib = Autoloader_.method :require_stdlib
    o = { }
    o[ :FileUtils ] =
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set  ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib
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

    Basic__ = sidesys[ :Basic ]

    Basic_Fields = -> * x_a do
      MetaHell__[]::Basic_Fields.via_iambic x_a
    end

    Bound_field_reflection_class = -> do
      Basic__[]::Field::Reflection::Bound_
    end

    Box = -> do
      Basic__[]::Box.new
    end

    Box_class = -> do
      Basic__[]::Box
    end

    Clear_pwd_cache = -> do
      Headless__[]::CLI::PathTools.clear
    end

    CLI_DSL = -> mod do
      mod.extend Porcelain__[]::Legacy::DSL
    end

    CLI_lipstick = -> * x_a do
      Face__[]::CLI::Lipstick.new( * x_a )
    end

    CLI_pen = -> do
      Headless__[]::CLI::Pen::SERVICES
    end

    CLI_stylify = -> a, b do
      Headless__[]::CLI::Pen::FUN::Stylify[ a, b ]
    end

    CLI_stylify_proc = -> do
      Headless__[]::CLI::Pen::FUN::Stylify
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.via_iambic x_a
    end

    CLI_tree_glyph_sets = -> do
      Headless__[]::CLI::Tree::Glyph::Sets
    end

    CLI_tree_glyphs = -> do
      Headless__[]::CLI::Tree::Glyphs
    end

    Contoured_fields = -> client, * x_a do
      MetaHell__[]::Fields.contoured.from_iambic_and_client x_a, client
    end

    Distill_proc = -> do
      Callback_.distill
    end

    EN_add_methods = -> * i_a do
      Headless__[]::SubClient::EN_FUN[ * i_a ]
    end

    Enhance_as_API_normalizer = -> x, * x_a do
      Face__[]::API::Normalizer_.enhance_client_class x, * x_a
    end

    Entity_via_iambic = -> x_a do
      client = x_a.fetch 0
      :fields == x_a.fetch( 1 ) or raise ::ArgumentError
      x_a[ 0, 2 ] = EMPTY_A__
      Basic_Fields[ :client, client,
        :absorber, :initialize,
        :field_i_a, x_a ]
    end
    EMPTY_A__ = [].freeze  # etc

    Face__ = sidesys[ :Face ]

    Field_front_expression_agent = -> a, b do
      Face__[]::API::Normalizer_::Field_Front_Exp_Ag_.new a, b
    end

    Fields_from_methods = -> *a, p do
      MetaHell__[]::Fields::From.methods.iambic_and_block a, p
    end

    Funcy_globful = -> x do
      MetaHell__[]::Funcy[ x ]
    end

    Funcy_globless = -> x do
      MetaHell__[]::Funcy_globless[ x ]
    end

    Hack_label_proc = -> do
      Face__[]::API::Normalizer_::Hack_label
    end

    Headless__ = sidesys[ :Headless ]

    Iambic = -> * x_a do
      Face__[]::Iambic.from_iambic x_a
    end

    Inspect_proc = -> do
      Basic__[]::FUN::Inspect__
    end

    InformationTactics__ = sidesys[ :InformationTactics ]

    MetaHell__ = sidesys[ :MetaHell ]

    Order_proxy = -> x do
      Basic__[]::Hash::Order_Proxy.new x
    end

    Porcelain__ = sidesys[ :Porcelain ]

    Power_Scanner = -> * x_a do
      Basic__[]::List::Scanner::Power.from_iambic x_a
    end

    Pretty_path_proc = -> do
      Headless__[]::CLI::PathTools::FUN::Pretty_path
    end

    Spec_rb = -> do
      TestSupport__[]::FUN::Spec_rb[]
    end

    Stock_API_expression_agent = -> do
      Face__[]::CLI::Client::API_Integration_::EXPRESSION_AGENT_
    end

    Struct = -> * i_a do
      Basic__[]::Struct.from_i_a i_a
    end

    Summarize_time = -> x do
      InformationTactics__[]::Summarize::Time[ x ]
    end

    TestSupport__ = sidesys[ :TestSupport ]

    Touch_constant_reader = -> * a do
      MetaHell__[]::FUN::Touch_constant_reader_[ *a ]
    end

    Tree_traversal = -> do
      Treelib__[]::Traversal.new
    end

    Tree_MMs_and_IMs = -> mod do
      _tree = Treelib__[]
      mod.extend _tree::ModuleMethods
      mod.include _tree::InstanceMethods
    end

    Treelib__ = memo[ -> do
      Porcelain__[]::Tree
    end ]

    Unbound_method_curry = -> x do
      Basic__[]::Method::Curry::Unbound.new x
    end

    Write_isomorphic_option_parser_options = -> * a do
      Face__[]::CLI::Client::API_Integration_::OP_.new( * a ).execute
    end
  end
end
