module Skylab::InformationTactics

  module Library_  # :+[#su-001]

    stdlib, gemlib = FUN.at :require_stdlib, :require_gemlib
    o = { }
    o[ :Levenshtein ] = gemlib
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
