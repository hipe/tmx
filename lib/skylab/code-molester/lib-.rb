module Skylab::CodeMolester

  module Library_

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

    sidesys = Autoloader_.build_require_sidesystem_proc

    define_singleton_method :_memoize, Callback_::Memoize

    Basic = sidesys[ :Basic ]

    Bsc_ = Basic

    Brazen = sidesys[ :Brazen ]

    Cache_pathname = _memoize do
      module CM_::Cache
        _p = Cache_pathname_lib[].cache_pathname_proc_via_module(
          self, :abbrev, 'cm' )
        define_singleton_method :pathname, _p
        self
      end.pathname
    end

    Cache_pathname_base = -> do
      System[].defaults.cache_pathname
    end

    Cache_pathname_lib = -> do
      System[].filesystem.cache
    end

    CLI_errstream_IO = -> do
      HL__[]::CLI::IO.some_errstream_IO
    end

    Constant_trouble = -> do
      Parse_lib___[]::DSL_DSL::Constant_Trouble
    end

    Delegating = -> mod, *a  do
      HL__[]::Delegating.apply_iambic_on_client a, mod
    end

    Entity_inflection = -> mod_name do
      HL__[]::Entity::Inflection.new mod_name
    end

    Face__ = sidesys[ :Face ]

    Field_box_enhance = -> x, p do
      Basic[]::Field.box.via_client_and_proc x, p
    end

    Field_reflection = -> x do
      Basic[]::Field.reflection[ x ]
    end

    Field_reflection_enhance = -> x do
      Basic[]::Field.reflection.enhance x
    end

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    HL__ = sidesys[ :Headless ]

    Hu___ = sidesys[ :Human ]

    Hash_lib = -> do
      Basic[]::Hash
    end

    IO_chunker_yielder = -> p do
      HL__[]::IO::Mappers::Chunkers::Functional.new p
    end

    MH__ = sidesys[ :MetaHell ]

    Model_enhance = -> x, p do
      Face__[]::Model.enhance x, & p
    end

    Module_accessors = -> do
      MH__[]::Module::Accessors
    end

    Module_lib = -> do
      Basic[]::Module
    end

    New_event_lib = -> do
      Brazen[].event
    end

    NLP_EN_methods = -> mod do
      Hu___[]::NLP::EN::Methods[ mod ]
    end

    Old_event_lib = -> do
      Face__[]::Model::Event
    end

    Parse_lib___ = sidesys[ :Parse ]

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    Simple_shell = -> a do
      MH__[]::Enhance::Shell.new a
    end

    String_lib = -> do
      Basic[]::String
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    System_default_tmpdir_pathname = _memoize do
      System[].filesystem.tmpdir_pathname.join 'co-mo'
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, CM_ )

  end

  LIB_ = Lib_::INSTANCE

end
