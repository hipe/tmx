module Skylab::SubTree

  module Library_  # :+[#su-001]

    stdlib, subsys = FUN.at :require_stdlib, :require_subsystem
    o = { }
    o[ :Face  ] = subsys
    o[ :FileUtils ] = stdlib
    o[ :InformationTactics ] = subsys
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set  ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :TestSupport ] = subsys
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end
end
