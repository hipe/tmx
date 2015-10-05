module Skylab::Human

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    gemlib = stdlib

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Levenshtein = gemlib[ :Levenshtein ]

    Parse = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

    String_scanner = -> s do
      require 'strscan'
      ::StringScanner.new s
    end

    Time = stdlib[ :Time ]

  end
end