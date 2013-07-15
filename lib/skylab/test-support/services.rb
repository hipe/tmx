module Skylab::TestSupport

  module Services

    def self.touch i
      const_defined? i, false or const_get i, false
      nil
    end

    o = { }
    subproduct, stdlib = MetaHell::FUN.at :require_subproduct, :require_stdlib
    o[:Basic] = subproduct
    o[:Benchmark] = stdlib
    o[:DRb] = -> _ { require 'drb/drb' ; ::DRb }
    o[:Face] = subproduct
    o[:FileUtils] = stdlib
    o[:Headless] = subproduct
    o[:JSON] = stdlib
    o[:MetaHell] = -> _ { require 'skylab/meta-hell/core' ; ::Skylab::MetaHell }
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Porcelain] = subproduct
    o[:StringIO] = stdlib
    o[:Tmpdir] = -> _ { require 'tmpdir' ; ::Dir }  # Dir.tmpdir

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
