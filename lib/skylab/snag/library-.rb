module Skylab::Snag

  module Library_  # :+[#su-001]

    MetaHell::MAARS[ self ]

    stdlib, subsystem = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem

    o = { }
    o[ :Basic ] = subsystem
    o[ :DateTime ] = o[ :FileUtils ] = o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Porcelain__ ] = -> _ { subsystem[ :Porcelain ] }
    o[ :Shellwords ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Tree ] = -> _ { self::Porcelain__::Tree }

    def self.const_missing c
      if (( p = self::H_[ c ] ))
        const_set c, p[ c ]
      else
        super
      end
    end

    H_ = o.freeze
  end

  module Lib_
    Basic_fields = -> client, * i_a do
      MetaHell__[]::Basic_Fields.via_field_i_a_and_client i_a, client
    end
    Basic_Fields = -> * x_a do
      if x_a.length.zero?
        MetaHell__[]::Basic_Fields
      else
        MetaHell__[]::Basic_Fields.via_iambic x_a
      end
    end
    MetaHell__ = -> do
      Snag_::MetaHell  # for now
    end
  end
end
