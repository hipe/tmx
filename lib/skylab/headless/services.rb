module Skylab::Headless

  module Services                 # just lazy-loading of stdlib nerks

    stdlib, subsys = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem
    o = { }
    o[:Basic] = subsys
    o[:CodeMolester] = subsys
    o[:FileUtils] = stdlib
    o[:Open3] = stdlib
    o[:Open4] = -> { ::Skylab::Subsystem::FUN.require_quietly[ 'open4' ]; ::Open4 }
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:PubSub] = subsys
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:Tmpdir] = -> _ { require 'tmpdir' ; ::Dir }
    o[:TreetopTools] = subsys

    o.freeze

    extend Autoloader::Methods  # you need it in your chain now
    class << self               # because of this, used below
      alias_method :svcs_original_const_missing, :const_missing
    end

    define_singleton_method :const_missing do |k|
      x = o.fetch( k ) { load_service k }.call( k )
      if true == x                             # (this makes a sketchy
        if const_defined? k, false             # assumption..)
          const_get k, false
        else
          # less confusing than: svcs_original_const_missing (from autol.)
          raise ::NameError.new "uninitialized constant #{ self }::#{ k } #{
            }- your custom loader should initialize it and did not."
        end
      else                                     # you loaded e.g. a toplevel
        const_set k, x                         # stdlib module, now set it
        x                                      # as a constant of yours
      end
    end

    def self.load_service const
      svcs_original_const_missing const
      mod = const_get const, false
      core_pn = mod.dir_pathname.join "core#{ Autoloader::EXTNAME }"
      if core_pn.exist?
        load core_pn.to_s  # change to require as necessary
      end
      -> _ { true }
    end
  end
end
