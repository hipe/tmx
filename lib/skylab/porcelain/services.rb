module Skylab::Porcelain

  module Services

    h = { }

    define_singleton_method( :o ) { |const, block| h[const] = block }

    o :OptionParser  , -> { require 'optparse'   ; ::OptionParser  }
    o :StringScanner , -> { require 'strscan'    ; ::StringScanner }

    # (if you need to, check out my-tree)
    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
