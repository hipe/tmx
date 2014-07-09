module Skylab::Git

  module Library_  # :+[#su-001]

    stdlib, sidesys = Autoloader_.at :require_stdlib, :require_sidesystem

    o = { }
    o[ :Basic ] = sidesys
    o[ :FileUtils ] = stdlib
    o[ :Headless ] = sidesys
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
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
