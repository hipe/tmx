module Skylab::Snag

  module Library_  # :+[#su-001]

    MetaHell::MAARS[ self ]

    stdlib, subsystem = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem

    o = { }
    o[ :Basic ] = subsystem
    o[ :DateTime ] = o[ :FileUtils ] = o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Shellwords ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

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
