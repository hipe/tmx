module Skylab::Snag

  module Services  # :+[#su-001]

    MetaHell::MAARS[ self ]

    stdlib = ::Skylab::Subsystem::FUN.require_stdlib
    o = { }
    o[:DateTime] = stdlib
    o[:FileUtils] = stdlib
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Shellwords] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    def self.const_missing c
      if (( p = self::H_[ c ] ))
        const_set c, p[ c ]
      else
        super
      end
    end

    H_ = o.freeze
  end
end
