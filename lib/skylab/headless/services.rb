module Skylab::Headless
  module Services                 # just lazy-loading of stdlib nerks

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Shellwords   , -> { require 'shellwords' ; ::Shellwords }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
