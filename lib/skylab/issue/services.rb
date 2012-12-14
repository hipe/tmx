module Skylab::Issue
  module Services

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :DateTime     , -> { require 'date'       ; ::DateTime }
    o :FileUtils    , -> { require 'fileutils'  ; ::FileUtils }
    o :Open3        , -> { require 'open3'      ; ::Open3 }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
