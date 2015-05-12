module Skylab::Human

  module Lib_

    _sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    gemlib = stdlib

    Levenshtein = gemlib[ :Levenshtein ]

    Time = stdlib[ :Time ]

  end
end
