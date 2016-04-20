module Skylab::TestSupport

  # (was [#001]:the-system-node)

  module Library_

    stdlib = Autoloader_.method :require_stdlib
    gemlib = stdlib

    o = { }

    o[ :Adsf ] = gemlib
    o[ :Benchmark ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Rack ] = gemlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    def self.const_missing c
      const_set c, H___.fetch( c )[ c ]
    end
    H___ = o.freeze

    def self.touch * i_a
      i_a.each do |i|
        const_get i, false
      end ; nil
    end
  end

  _instance = module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Git = sidesys[ :Git ]
    Human = sidesys[ :Human ]

    Match_test_dir_proc = -> do
      mtdp = nil
      -> do
        mtdp ||= Home_.constant( :TEST_DIR_NAME_A ).method( :include? )
      end
    end.call

    Parse = sidesys[ :Parse ]  # only for 1 tree runner plugin (greenlist)
    Permute = sidesys[ :Permute ]
    Plugin = sidesys[ :Plugin ]

    Stderr = -> { ::STDERR }  # [#001.E]: why access system resources this way

    Stdout = -> { ::STDOUT }

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]
    Task = sidesys[ :Task ]
    TMX = sidesys[ :TMX ]

    Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )
  end

  LIB_ = _instance
end
