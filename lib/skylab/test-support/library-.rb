module Skylab::TestSupport

  module System  # [#057]:the-system-node
    class << self
      def stderr
        Lib_::Stderr[]
      end
    end
  end

  module Library_  # read [#057] the library narrative #into. :+[#su-001]

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

    Autoload_const_missing_class = -> do
      MetaHell__[]::MAARS::Const_Missing_
    end

    Autoloader__ = memoize[ -> do
      Skylab__[]::Autoloader
    end ]

    Basic__ = sidesys[ :Basic ]

    Box = -> do
      Basic__[]::Box.new
    end

    CLI = -> do
      Face__[]::CLI
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.via_iambic x_a
    end

    CLI_table_class = -> do
      Face__[]::CLI::Table
    end

    Default_core_file = -> do
      Autoloader_.default_core_file
    end

    Enhancement_shell = -> * i_a do
      MetaHell__[]::Enhance::Shell.new i_a
    end

    Fields_contoured = -> mod, * x_a do
      MetaHell__[]::FUN::Fields_::Contoured_.from_iambic_and_client x_a, mod
    end

    Funcy = -> mod do
      MetaHell__[]::Funcy[ mod ]
    end

    Face__ = sidesys[ :Face ]

    Headless__ = sidesys[ :Headless ]

    Heavy_plugin = -> do
      Face__[]::Plugin
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
      Autoloader__[]::FUN::Methodize[ i ]
    end

    Name_from_const_to_path = -> x do
      Autoloader__[]::FUN::Pathify[ x ]
    end

    Name_from_path_to_const = -> pn do
      Autoloader__[]::FUN::Constantize[ pn ]
    end

    Name_from_sanitized_file_to_const_proc = -> do
      Autoloader__[]::FUN::Constantize::Sanitized_file
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
      # [#057]:the-reasons-to-access-system-resources-this-way
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

    Text_patch = -> do
      Headless__[]::Text::Patch
    end

    Transitional_autoloader = -> mod, file do
      _dpn = ::Pathname.new( file ).sub_ext ''
      MetaHell__[]::MAARS[ mod, _dpn ] ; nil
    end
  end
end
