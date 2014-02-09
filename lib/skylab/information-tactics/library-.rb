module Skylab::InformationTactics

  module Library_  # :+[#su-001]

    gemlib = stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :Levenshtein ] = gemlib
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end

    def self.touch i
      const_defined?( i, false ) or const_get( i, false ) ; nil
    end
  end
end
