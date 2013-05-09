module Skylab::Headless

  module Services                 # just lazy-loading of stdlib nerks

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :Basic        , -> { require 'skylab/basic/core' ; ::Skylab::Basic }
    o :CodeMolester , -> { require 'skylab/code-molester/core'
                                                  ::Skylab::CodeMolester }
    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Open3        , -> { require 'open3'      ; ::Open3 }
    o :Open4        , -> { require_quietly 'open4'; ::Open4 }
    o :OptionParser , -> { require 'optparse'   ; ::OptionParser }
    o :PubSub       , -> { require 'skylab/pub-sub/core' ; ::Skylab::PubSub }
    o :Set          , -> { require 'set'        ; ::Set }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords }
    o :StringIO     , -> { require 'stringio'   ; ::StringIO }
    o :StringScanner, -> { require 'strscan'    ; ::StringScanner }
    o :TreetopTools , -> { require 'skylab/treetop-tools/core'
                                                  ::Skylab::TreetopTools }

    extend Autoloader::Methods  # you need it in your chain now
    class << self               # because of this, used below
      alias_method :svcs_original_const_missing, :const_missing
    end

    define_singleton_method :const_missing do |k|
      func = h.fetch k do load_service k end
      x = instance_exec(& func )
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

    def self.require_quietly path
      Headless::FUN.require_quietly[ path ]
    end

    def self.load_service const
      svcs_original_const_missing const
      mod = const_get const, false
      core_pn = mod.dir_pathname.join "core#{ Autoloader::EXTNAME }"
      if core_pn.exist?
        load core_pn.to_s  # change to require as necessary
      end
      -> { true }
    end
  end
end
