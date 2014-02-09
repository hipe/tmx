module Skylab::CodeMolester

  module Library_  # :+[#su-001]

    quietly, stdlib = Autoloader_.at :require_quietly,  :require_stdlib

    o = { }
    o[ :FileUtils ] =
    o[ :Psych ] =
    o[ :Set ] =
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Treetop ] = quietly
    o[ :YAML ] = stdlib

    define_singleton_method :const_missing do |i|
      o.key? i or super i
      const_set i, o.fetch( i )[ i ]
    end

    class << self
      def touch i
        const_defined?( i, false ) or const_get( i, false ) ; nil
      end
    end
  end

  module Lib_

    memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    Add_the_pool_method_known_as_with_instance = -> x do
      MetaHell__[]::Pool.enhance( x ).with_with_instance
    end

    Basic__ = sidesys[ :Basic ]

    Cache_pathname = memo[ -> do
      module CodeMolester::Cache
        define_singleton_method :pathname, (
          IO_cache[].build_cache_pathname_function_for self do
            abbrev 'cm'
          end )
        self
      end.pathname
    end ]

    CLI_errstream_IO = -> do
      Headless__[]::CLI::IO.some_errstream_IO
    end

    Constant_trouble = -> do
      MetaHell__[]::DSL_DSL::Constant_Trouble
    end

    Delegating = -> mod, *a  do
      Headless__[]::Delegating.apply_iambic_on_client a, mod
    end

    Dry_IO_stub = -> do
      Headless__[]::IO::DRY_STUB
    end

    Entity_inflection = -> mod_name do
      Headless__[]::Entity::Inflection.new mod_name
    end

    Evented_list_articulation = -> x, p do
      Basic__[]::List::Evented::Articulation x, & p
    end

    Face__ = sidesys[ :Face ]

    Field_box_enhance = -> x, p do
      Basic__[]::Field::Box.enhance x, & p
    end

    Field_reflection = -> x do
      Basic__[]::Field::Reflection[ x ]
    end

    Field_reflection_enhance = -> x do
      Basic__[]::Field::Reflection.enhance x
    end

    Fields = -> * x_a do
      MetaHell__[]::FUN::Fields_.via_iambic x_a
    end

    File_utils = -> p do
      Headless__[]::IO::FU.new p
    end

    Headless__ = sidesys[ :Headless ]

    Hash_functions = -> do
      Basic__[]::Hash::FUN
    end

    IO_cache = -> do
      Headless__[]::IO::Cache
    end

    IO_chunker_yielder = -> p do
      Headless__[]::IO::Interceptors::Chunker::F.new p
    end

    Inspect_proc = -> do
      Basic__[]::FUN::Inspect__
    end

    List_scanner = -> x do
      Basic__[]::List::Scanner[ x ]
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Model_enhance = -> x, p do
      Face__[]::Model.enhance x, & p
    end

    Model_event = -> do
      Face__[]::Model::Event
    end

    Module_accessors = -> do
      MetaHell__[]::Module::Accessors
    end

    Module_mutex = -> p do
      MetaHell__[]::Module::Mutex[ p ]
    end

    Mustache_rx = -> do
      Basic__[]::String::MUSTACHE_RX
    end

    Name_function = -> do
      Headless__[]::Name::Function
    end

    NLP_EN_methods = -> mod do
      Headless__[]::NLP::EN::Methods[ mod ]
    end

    Open_box = -> do
      MetaHell__[]::Formal::Box::Open.new
    end

    Procs_as_methods = -> * i_a, & p do
      MetaHell__[]::Function::Class.from_i_a_and_p i_a, p
    end

    Simple_shell = -> a do
      MetaHell__[]::Enhance::Shell.new a
    end

    System_default_tmpdir_pathname = memo[ -> do
      Headless__[]::System.defaults.tmpdir_pathname.join 'co-mo'
    end ]
  end
end
