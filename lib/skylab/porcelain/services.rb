module Skylab::Porcelain

  module Services

    o = { }
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |k|
      const_set k, o.fetch( k )[ k ]
    end
  end
end
