module Skylab::FileMetrics

  module Services

    extend MAARS

    h = { }

    define_singleton_method( :o ) { |const, block| h[const] = block }

    o :Ncurses       , -> { require 'ncurses'    ; ::Ncurses }
    o :Open3         , -> { require 'open3'      ; ::Open3 }
    o :Shellwords    , -> { require 'shellwords' ; ::Shellwords }
    o :StringIO      , -> { require 'stringio'   ; ::StringIO }
    o :StringScanner , -> { require 'strscan'    ; ::StringScanner }

    define_singleton_method :const_missing do |k|
      if h.key? k
        const_set k, h.fetch( k ).call
      else
        ohai = super( k )
        if ! const_defined? k, false
          fail "scott whallan"
        end
        ohai
      end
    end
  end
end
