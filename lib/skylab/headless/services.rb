module Skylab::Headless
  module Services                 # just lazy-loading of stdlib nerks

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :File         , -> { require_relative 'services/file/core' }
    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Open3        , -> { require 'open3'      ; ::Open3 }
    o :OptionParser , -> { require 'optparse'   ; ::OptionParser }
    o :Patch        , -> { require_relative 'services/patch/core' }
    o :Producer     , -> { require_relative 'services/producer' }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords }
    o :StringIO     , -> { require 'stringio'   ; ::StringIO }

    class << self
      alias_method :svcs_original_const_missing, :const_missing
    end

    define_singleton_method :const_missing do |k|
      x = h.fetch( k ).call
      if true == x
        if const_defined? k, false
          const_get k, false
        else
          # less confusing than: svcs_original_const_missing (from autol.)
          raise ::NameError.new "uninitialized constant #{ self }::#{ k } #{
            }- your custom loader should initialize it and did not."
        end
      else
        const_set k, x
        x
      end
    end
  end
end
