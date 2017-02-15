require 'skylab/common'

module Skylab::TaskExamples

  class << self

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def sidesystem_path
      @___ss_path ||= ::File.expand_path( '../../..', Home_.dir_path )
    end
  end  # >>

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  # --

  Common_task_ = -> do
    Home_.lib_.task
  end

  # --

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Home_dir_pn = -> do
      System_lib___[].services.environment.any_home_directory_pathname
    end

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Task = sidesys[ :Task ]
    System_lib = sidesys[ :System ]
  end

  # --

  module Library_  # :+[#su-001]

    # #todo etc

    class << self

      cache = {}
      define_method :o do | sym, & p |
        cache[ sym ] = p
      end

      define_method :const_missing do | sym |
        x = cache.fetch( sym ).call
        const_set sym, x
        x
      end
    end  # >>

    o :FileUtils do
      require 'fileutils'
      ::FileUtils
    end

    o :Shellwords do
      require 'shellwords'
      ::Shellwords
    end

    o :StringIO do
      require 'stringio'
      ::StringIO
    end

    o :StringScanner do
      require 'strscan'
      ::StringScanner
    end
  end

  # --

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_S_ = ''
  Home_ = self
  Lazy_ = Common_::Lazy
  stowaway :Library_, 'lib-'
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = ' '
  Autoloader_[ TaskTypes = ::Module.new ]
  Textual_Old_Event_ = ::Struct.new :text, :stream_symbol
  UNABLE_ = false
  UNRELIABLE_ = :_unreliable_from_te_

  def self.describe_into_under y, _
    y << "ancient (ancient) proof-of-concept of \"task\""
  end
end
# #tombstone - CLI option parser (sort of) born 2011-11
