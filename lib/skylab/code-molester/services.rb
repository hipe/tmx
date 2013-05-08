module Skylab::CodeMolester

  module Services # being #watched [#mh-011] (this is instance four)

    h = { }

    define_singleton_method :o do |const, f|
      h[const] = f
    end

    o :Basic,         -> { Headless::Services::Basic }

    o :Face,          -> { require 'skylab/face/core' ; ::Skylab::Face }

    o :FileUtils,     -> { require 'fileutils' ; ::FileUtils }

    o :Psych,         -> { require 'psych'    ; ::Psych }

    o :StringIO,      -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan'  ; ::StringScanner }

    o :Treetop,       -> do
                           Headless::FUN.require_quietly[ 'treetop' ]
                                                ::Treetop
                         end

    o :YAML,          -> { require 'yaml'     ; ::YAML }


    extend MAARS  # LOOK.

    define_singleton_method :const_missing do |const|
      if h.key? const
        const_set const, h.fetch( const ).call
      else
        super const  # KRAY!
      end
    end
  end
end
