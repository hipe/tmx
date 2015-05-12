module Skylab::Human

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    gemlib = stdlib

    Basic = sidesys[ :Basic ]

    Levenshtein = gemlib[ :Levenshtein ]

    Parse = sidesys[ :Parse ]

    Time = stdlib[ :Time ]

  end
end
