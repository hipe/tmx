module Skylab::Headless
  module Services                 # just lazy-loading of stdlib nerks

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :CodeMolester , -> { require 'skylab/code-molester/core'
                                                  ::Skylab::CodeMolester }
    o :File         , -> { require_relative 'services/file/core' }
    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Open3        , -> { require 'open3'      ; ::Open3 }
    o :Open4        , -> { require_quietly 'open4'; ::Open4 }
    o :OptionParser , -> { require 'optparse'   ; ::OptionParser }
    o :Patch        , -> { require_relative 'services/patch/core' }
    o :PubSub       , -> { require 'skylab/pub-sub/core' ; ::Skylab::PubSub }
    o :Producer     , -> { require_relative 'services/producer' }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords }
    o :StringIO     , -> { require 'stringio'   ; ::StringIO }
    o :StringScanner, -> { require 'strscan'    ; ::StringScanner }
    o :TreetopTools , -> { require 'skylab/treetop-tools/core'
                                                  ::Skylab::TreetopTools }

    class << self
      alias_method :svcs_original_const_missing, :const_missing
    end

    define_singleton_method :const_missing do |k|
      x = instance_exec(& h.fetch( k ))
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
  end
end
