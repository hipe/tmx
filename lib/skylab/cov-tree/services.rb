module Skylab::CovTree
  module Services
    h = { }
    define_singleton_method( :o ) { |const, block| h[const] = block }

    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Open3        , -> { require 'open3'      ; ::Open3 }
    o :Set          , -> { require 'set'        ; ::Set }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords }
    o :StringScanner, -> { require 'strscan'    ; ::StringScanner }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
