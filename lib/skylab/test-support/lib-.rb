module Skylab::TestSupport

  # (was [#001]:the-system-node)

  module Library_

    gemlib = stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :Adsf ] = gemlib
    o[ :Benchmark ] = stdlib
    o[ :FileUtils ] = stdlib
    o[ :JSON ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Rack ] = gemlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    def self.const_missing c
      const_set c, H_.fetch( c )[ c ]
    end
    H_ = o.freeze

    def self.touch * i_a
      i_a.each do |i|
        const_get i, false
      end ; nil
    end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    _Face = sidesys[ :Face ]

    API = -> do
      _Face[]::API
    end

    API_normalizer_lib = -> do
      _Face[]::API::Normalizer_
    end

    API_normalizer = API_normalizer_lib

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Box = -> do
      Basic[]::Box.new
    end

    CLI_client_base_class = -> do
      _Face[]::CLI::Client
    end

    CLI_table = -> * x_a do
      _Face[]::CLI::Table.call_via_iambic x_a
    end

    Default_core_file = -> do
      Autoloader_.default_core_file
    end

    _HL = sidesys[ :Headless ]
    EN_add_methods = -> mod, * x_a do
      _HL[].expression_agent.NLP_EN_methods.on_mod_via_iambic mod, x_a
     end

    Enhancement_shell = -> * i_a do
      Plugin[]::Bundle::Enhance::Shell.new i_a
    end

    Permute = sidesys[ :Permute ]

    Plugin = sidesys[ :Plugin ]

    Properties_stack_frame = -> * a do
      Brazen[]::Property::Stack.common_frame.call_via_arglist a
    end

    _Snag = sidesys[ :Snag ]

    Hashtag = -> do
      _Snag[]::Models::Hashtag
    end

    Heavy_plugin_lib = -> do
      _Face[]::Plugin
    end

    Heavy_plugin = Heavy_plugin_lib

    Iambic_scanner = -> do
      Callback_::Polymorphic_Stream
    end

    IO = -> do
      System_lib[]::IO
    end

    _Hu = sidesys[ :Human ]

    Levenshtein = -> * x_a do
      _Hu[]::Levenshtein.call_via_iambic x_a
    end

    Name_from_const_to_method = -> i do
      Callback_::Name.lib.methodize i
    end

    Name_from_const_to_path = -> x do
      Callback_::Name.lib.pathify x
    end

    Name_from_path_to_const = -> pn do
      Callback_::Name.lib.constantize pn
    end

    Name_sanitize_for_constantize_file_proc = -> do
      Callback_::Name.lib.constantize_sanitize_file
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Skylab__ = Callback_.memoize do
      require_relative DOT_DOT_
      ::Skylab
    end

    Stderr = -> { ::STDERR }  # [#001.E]: why access system resources this way

    Stdout = -> { ::STDOUT }

    Stream = -> x do
      Callback_::Scn.try_convert x
    end

    Struct = -> * i_a do
      Basic[]::Struct.make_via_arglist i_a
    end

    _HL = sidesys[ :Headless ]

    SUNSETTING_CLI_lib = -> do
      _HL[]::CLI
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Tmpdir = -> do
      System[].filesystem.tmpdir
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )
  end

  LIB_ = Lib_::INSTANCE

end
