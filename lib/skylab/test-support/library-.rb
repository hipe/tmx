module Skylab::TestSupport

  module Library_  # :+[#su-001]

    stdlib, subsys, gemlib =
      FUN.at :require_stdlib, :require_subsystem, :require_gemlib
    o = { }
    o[ :Adsf ] = gemlib
    o[ :Basic ] = subsys
    o[ :Benchmark ] = stdlib
    o[ :DRb ] = -> _ { require 'drb/drb' ; ::DRb }
    o[ :Face ] = subsys
    o[ :FileUtils ] = stdlib
    o[ :Headless ] = subsys
    o[ :JSON ] = stdlib
    o[ :MetaHell ] = subsys
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Porcelain ] = subsys
    o[ :Rack ] = gemlib
    o[ :StringIO ] = stdlib
    o[ :Tmpdir ] = -> _ { require 'tmpdir' ; ::Dir }  # Dir.tmpdir

    def self.const_missing c
      const_set c, H_.fetch( c )[ c ]
    end

    H_ = o.freeze
  end
end
