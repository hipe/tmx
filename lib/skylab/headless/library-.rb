module Skylab::Headless

  module Library_  # :+[#su-001]

    stdlib, subsys = Autoloader_.at :require_stdlib, :require_subsystem

    o = { }
    o[ :Basic ] = subsys
    o[ :Boxxy ] = -> _ { self::MetaHell::Boxxy }
    o[ :Bundle ] = -> _ { self::MetaHell::Bundle }
    o[ :CodeMolester ] = subsys
    o[ :FileUtils ] = stdlib
    o[ :Function ] = -> _ { self::MetaHell::Function }
    o[ :Funcy ] = -> _ { self::MetaHell::Funcy }
    o[ :Formal_Box ] = -> _ { self::MetaHell::Formal::Box }
    o[ :FUN_Module ] = -> _ { self::MetaHell::FUN::Module }
    o[ :Function_Class ] = -> _ { self::MetaHell::Function::Class }
    o[ :InformationTactics ] = o[ :MetaHell ] = subsys
    o[ :MAARS ] = -> _ { self::MetaHell::MAARS }
    o[ :Module_Resolve ] = -> _ { self::MetaHell::Module::Resolve }
    o[ :Open3 ] = stdlib
    o[ :Open4 ] = -> { ::Skylab::Subsystem::FUN.require_quietly[  'open4'  ]; ::Open4 }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Callback ] = subsys
    o[ :Set ] = stdlib
    o[ :Shellwords ] = o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Tmpdir ] = -> _ { require 'tmpdir' ; ::Dir }
    o[ :TreetopTools ] = subsys

    # ~ just do it live and implement small things here potentially redundantly

    Memoize = -> p do
      p_ = -> { x = p[] ; p_ = -> { x } ; x }
      -> { p_.call }
    end

    def self.const_missing i
      const_set i, @o.fetch( i )[ i ]
    end ; @o = o.freeze
  end
end
