module Skylab::TestSupport

  # (was [#035]:the-system-node)

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

    API = -> do
      Face__[]::API
    end

    API_normalizer_lib = -> do
      Face__[]::API::Normalizer_
    end

    API_normalizer = API_normalizer_lib

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Box = -> do
      Basic[]::Box.new
    end

    CLI_client_base_class = -> do
      Face__[]::CLI::Client
    end

    CLI_pen = -> do
      HL__[]::CLI.pen
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.call_via_iambic x_a
    end

    Default_core_file = -> do
      Autoloader_.default_core_file
    end

    Enhancement_shell = -> * i_a do
      MH__[]::Enhance::Shell.new i_a
    end

    Entity = -> * a, & p do
      if a.length.nonzero? || p
        Brazen[]::Entity.call_via_arglist a, & p
      else
        Brazen[]::Entity
      end
    end

    Properties_stack_frame = -> * a do
      Brazen[].properties_stack.common_frame.call_via_arglist a
    end

    Funcy_globful = -> mod do
      MH__[].funcy_globful mod
    end

    Funcy_globless = -> mod do
      MH__[].funcy_globless mod
    end

    Face__ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    Hashtag = -> do
      Snag__[]::Models::Hashtag
    end

    Heavy_plugin_lib = -> do
      Face__[]::Plugin
    end

    Heavy_plugin = Heavy_plugin_lib

    Hu___ = sidesys[ :Human ]

    Iambic_scanner = -> do
      Callback_::Polymorphic_Stream
    end

    IO = -> do
      System_lib__[]::IO
    end

    Levenshtein = -> * x_a do
      Hu___[]::Levenshtein.call_via_iambic x_a
    end

    MH__ = sidesys[ :MetaHell ]

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

    Snag__ = sidesys[ :Snag ]

    Skylab__ = Callback_.memoize do
      require_relative DOT_DOT_
      ::Skylab
    end

    Stderr = -> { ::STDERR }
      # [#035]:the-reasons-to-access-system-resources-this-way
    Stdout = -> { ::STDOUT }

    Stream = -> x do
      Callback_::Scn.try_convert x
    end

    Struct = -> * i_a do
      Basic[]::Struct.make_via_arglist i_a
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Tmpdir = -> do
      System[].filesystem.tmpdir
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, TestSupport_ )
  end

  LIB_ = Lib_::INSTANCE

end
