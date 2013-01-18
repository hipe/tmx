module Skylab::Snag
  module Services

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :DateTime     , -> { require 'date'        ; ::DateTime }
    o :FileUtils    , -> { require 'fileutils'   ; ::FileUtils }
    o :Open3        , -> { require 'open3'       ; ::Open3 }
    o :OptionParser , -> { require 'optparse'    ; ::OptionParser }
    o :Shellwords   , -> { require 'shellwords'  ; ::Shellwords }
    o :StringScanner, -> { require 'strscan'     ; ::StringScanner }

    # --*--

    pathify = Autoloader::Inflection::FUN.pathify

    define_singleton_method :const_missing do |k|
      if h[k]
        const_set k, h.fetch( k ).call
      else
        require_relative "services/#{ pathify[ k ] }"
        if const_defined? k, false
          const_get k, false
        else
          raise ::NameError.new "no such service: #{ k.inspect }"
        end
      end
    end
  end
end
