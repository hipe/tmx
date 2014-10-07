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

    Brazen_ = Autoloader_.build_require_sidesystem_proc :Brazen

    Distill_proc = -> do
      Callback__[].distill
    end

    Ellipsify_to_length = -> d, s do
      Library_::Headless::CLI::FUN::Ellipsify_[ d, s ]
    end

    Levenshtein = -> do
      Library_::Headless::NLP::EN::Levenshtein
    end

    Method_added_muxer = -> *a do
      Brazen_[].method_added_muxer.via_arglist a
    end

    Scn = -> do
      Callback__[]::Scn
    end

    Strange = -> x do
      MetaHell_.strange x
    end
  end
end
