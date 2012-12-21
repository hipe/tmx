module Skylab::InformationTactics              # centralize std-lib deps,
  module Services                              # and lazy-load them as-needed.

    h = { }
    define_singleton_method( :o ) { |k, f| h[k] = f }

    o :Time,         -> { require 'time'        ; ::Time }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
