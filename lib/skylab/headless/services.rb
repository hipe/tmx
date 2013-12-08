module Skylab::Headless

  module Services  # :+[#su-001]

    stdlib, subsys = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem
    o = { }
    o[:Basic] = subsys
    o[:CodeMolester] = subsys
    o[:FileUtils] = stdlib
    o[:InformationTactics] = subsys
    o[:Open3] = stdlib
    o[:Open4] = -> { ::Skylab::Subsystem::FUN.require_quietly[ 'open4' ]; ::Open4 }
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:PubSub] = subsys
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:Tmpdir] = -> _ { require 'tmpdir' ; ::Dir }
    o[:TreetopTools] = subsys

    o.freeze

    @o = o

    MetaHell::MAARS[ self, :deferred ]

    def self.const_missing i
      if (( p = @o[ i ] ))
        const_set i, p[ i ]
      else
        x = super( i ) or fail "sanity - result expected"  # [#mh-040]
        (( pn = x.dir_pathname.join CORE_ )).exist? and load pn.to_s
        x
      end
    end

    CORE_ = "core#{ Autoloader::EXTNAME }"
  end
end
