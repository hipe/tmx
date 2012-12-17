module Skylab::GitStashUntracked               # centralize std-lib deps,
  module Services                              # and lazy-load them as-needed.

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :FileUtils   , -> { require 'fileutils'   ; ::FileUtils }
    o :Open3       , -> { require 'open3'       ; ::Open3 }
    o :OptionParser, -> { require 'optparse'    ; ::OptionParser }

    # --*--

    pathify = ::Skylab::Autoloader::Inflection::FUN.pathify

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
