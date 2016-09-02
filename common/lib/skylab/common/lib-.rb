module Skylab::Common

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

    strange = Lazy_.call do

      _LENGTH_OF_A_LONG_LINE = 120
      o = Basic[]::String.via_mixed.dup
      o.max_width = _LENGTH_OF_A_LONG_LINE
      o.to_proc
    end

    Strange = -> x do
      strange[][ x ]
    end

    String_IO = Lazy_.call do
      require 'stringio'
      ::StringIO
    end

    StringScanner = Lazy_.call do
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
