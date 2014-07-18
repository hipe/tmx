module Skylab::MetaHell

  module Library_  # :+[#su-001]

    stdlib, subsys = Autoloader_.at :require_stdlib, :require_sidesystem
    o = { }
    o[ :Basic ] =
    o[ :Callback ] =
    o[ :CodeMolester ] =
    o[ :Headless ] = subsys
    o[ :Open3 ] = stdlib
    o[ :Callback ] = subsys
    o[ :Set ] = o[ :Shellwords ] = stdlib

    def self.kick i
      const_get i, false ; nil
    end

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end

  module Lib_
    memo = MetaHell_::FUN::Memoize

    Callback__ = memo[ -> { Library_::Callback } ]

    Distill_proc = -> do
      Callback__[].distill
    end

    Levenshtein = -> do
      Library_::Headless::NLP::EN::Levenshtein
    end

    Scn = -> do
      Callback__[]::Scn
    end

    Strange = -> x do
      MetaHell_::Parse.strange x
    end
  end
end
