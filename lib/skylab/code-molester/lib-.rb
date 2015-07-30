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

    Brazen = sidesys[ :Brazen ]

    Cache_pathname = _memoize do
      module Home_::Cache
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

    _HL = sidesys[ :Headless ]

    CLI_errstream_IO = -> do
      _HL[]::CLI::IO.some_errstream_IO
    end

    _Parse_lib = sidesys[ :Parse ]

    Constant_trouble = -> do
      _Parse_lib[]::DSL_DSL::Constant_Trouble
    end

    Delegating = -> mod, *a  do
      _HL[]::Delegating.apply_iambic_on_client a, mod
    end

    Entity_inflection = -> mod_name do
      _HL[]::Entity::Inflection.new mod_name
    end

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

    Hash_lib = -> do
      Basic[]::Hash
    end

    IO_chunker_yielder = -> p do
      _HL[]::IO::Mappers::Chunkers::Functional.new p
    end

    Module_lib = -> do
      Basic[]::Module
    end

    _Hu = sidesys[ :Human ]

    NLP_EN_methods = -> mod do
      _Hu[]::NLP::EN::Methods[ mod ]
    end

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    Simple_shell = -> a do
      Plugin[]::Bundle::Enhance::Shell.new a
    end

    String_lib = -> do
      Basic[]::String
    end

    _System_lib = sidesys[ :System ]

    System = -> do
      _System_lib[].services
    end

    System_default_tmpdir_path = _memoize do

      ::File.join System[].filesystem.tmpdir_path, 'co-mo'
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )

  end

  LIB_ = Lib_::INSTANCE

end
