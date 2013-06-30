module Skylab::Snag

  module Services

    o = { }
    stdlib = MetaHell::FUN.require_stdlib
    o[:DateTime] = stdlib
    o[:FileUtils] = stdlib
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Shellwords] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    # --*--

    pathify = Autoloader::Inflection::FUN.pathify

    define_singleton_method :const_missing do |k|
      if o[k]
        const_set k, o.fetch( k )[ k ]
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
