module Skylab::TestSupport

  module System  # [#035]:the-system-node
    class << self
      def stderr
        Lib_::Stderr[]
      end
    end
  end

  module Library_  #  :+[#su-001]

    gemlib = stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :Adsf ] = gemlib
    o[ :Benchmark ] = stdlib
    o[ :FileUtils ] = stdlib
    o[ :JSON ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Rack ] = gemlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Tmpdir ] = -> _ { require 'tmpdir' ; ::Dir }  # Dir.tmpdir

    def self.const_missing c
      const_set c, H_.fetch( c )[ c ]
    end
    H_ = o.freeze

    def self.touch * i_a
      i_a.each do |i|
        const_get i, false
      end ; nil
    end
  end

  module Lib_

    memoize, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    API = -> do
      Face__[]::API
    end

    API_normalizer = -> do
      Face__[]::API::Normalizer_
    end

    Basic__ = sidesys[ :Basic ]

    Brazen__ = sidesys[ :Brazen ]

    Box = -> do
      Basic__[]::Box.new
    end

    CLI_client_base_class = -> do
      Face__[]::CLI::Client
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.via_iambic x_a
    end

    Default_core_file = -> do
      Autoloader_.default_core_file
    end

    Enhancement_shell = -> * i_a do
      MetaHell__[]::Enhance::Shell.new i_a
    end

    Entity = -> * a do
      if a.length.zero?
        Brazen__[]::Entity
      else
        Brazen__[]::Entity.via_arglist a
      end
    end

    Fields_contoured = -> mod, * x_a do
      MetaHell__[]::Fields.contoured.from_iambic_and_client x_a, mod
    end

    Funcy_globful = -> mod do
      MetaHell__[].funcy_globful mod
    end

    Funcy_globless = -> mod do
      MetaHell__[].funcy_globless mod
    end

    Face__ = sidesys[ :Face ]

    Headless__ = sidesys[ :Headless ]

    Heavy_plugin = -> do
      Face__[]::Plugin
    end

    Iambic_scanner = -> do
      Callback_.iambic_scanner
    end

    IO = -> do
      Headless__[]::IO
    end

    Let = -> do
      MetaHell__[]::Let
    end

    Let_methods = -> mod do
      mod.extend MetaHell__[]::Let::ModuleMethods
      mod.include MetaHell__[]::Let::InstanceMethods
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Name_from_const_to_method = -> i do
      Callback_::Name.lib.methodize i
    end

    Name_from_const_to_path = -> x do
      Callback_::Name.lib.pathify x
    end

    Name_from_path_to_const = -> pn do
      Callback_::Name.lib.constantize pn
    end

    Name_sanitize_for_constantize_file_proc = -> do
      Callback_::Name.lib.constantize_sanitize_file
    end

    Procs_as_methods = -> * i_a, & p do
      MetaHell__[]::Function::Class.from_i_a_and_p i_a, p
    end

    Proc_as_method = -> mod do
      MetaHell__[]::Function.enhance mod
    end

    Scanner = -> x do
      Basic__[]::List::Scanner[ x ]
    end

    Stderr = -> { ::STDERR }
      # [#035]:the-reasons-to-access-system-resources-this-way
    Stdout = -> { ::STDOUT }

    Skylab__ = memoize[ -> do
      require_relative '..'
      ::Skylab
    end ]

    Struct = -> * i_a do
      Basic__[]::Struct.from_i_a i_a
    end

    Template = -> s do
      Basic__[]::String::Template.from_string s
    end

    Tmpdir = -> do
      Headless__[]::IO::Filesystem::Tmpdir
    end
  end
end
