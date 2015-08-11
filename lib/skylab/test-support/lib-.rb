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

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Box = -> do
      Basic[]::Box.new
    end

    Default_core_file = -> do
      Autoloader_.default_core_file
    end

    Enhancement_shell = -> * i_a do
      Plugin[]::Bundle::Enhance::Shell.new i_a
    end

    Function_chain = -> * p_a do
      Basic[]::Function.chain p_a
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

    Human = sidesys[ :Human ]

    Iambic_scanner = -> do
      Callback_::Polymorphic_Stream
    end

    IO = -> do
      System_lib[]::IO
    end

    Levenshtein = -> * x_a do
      Human[]::Levenshtein.call_via_iambic x_a
    end

    Match_test_dir_proc = -> do
      mtdp = nil
      -> do
        mtdp ||= Home_.constant( :TEST_DIR_NAME_A ).method( :include? )
      end
    end.call

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

    Skylab__ = Callback_.memoize do
      require_relative DOT_DOT_
      ::Skylab
    end

    Stderr = -> { ::STDERR }  # [#001.E]: why access system resources this way

    Stdout = -> { ::STDOUT }

    Struct = -> * i_a do
      Basic[]::Struct.make_via_arglist i_a
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
