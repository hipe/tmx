module Skylab::Porcelain

  module Library_  # :+[#su-001]

    o = { }
    o[ :Basic ] = -> _ { require 'skylab/basic/core' ; ::Skylab::Basic }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :StringIO ] = ::Skylab::Subsystem::FUN.require_stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end

  module Lib_
    Basic_Fields = -> * x_a do
      if x_a.length.zero?
        MetaHell::Basic_Fields
      else
        MetaHell::Basic_Fields.via_iambic x_a
      end
    end
  end
end
