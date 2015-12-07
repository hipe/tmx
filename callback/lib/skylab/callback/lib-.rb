module Skylab::Callback

  module Lib_  # :+[#ss-001]

    sidesys = Autoloader.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Parse = sidesys[ :Parse ]
    Plugin = sidesys[ :Plugin ]

    Stdlib_option_parser = -> do
      require 'optparse'
      ::OptionParser
    end

    Strange = -> do
      p = -> x do
        _LENGTH_OF_A_LONG_LINE = 120
        p = Basic[]::String.via_mixed.curry[ _LENGTH_OF_A_LONG_LINE ]
        p[ x ]
      end
      -> x { p[ x ] }
    end.call

    StringScanner = -> do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]
  end
end
