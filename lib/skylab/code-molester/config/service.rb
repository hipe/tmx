module Skylab::CodeMolester

  class Config::Service

    # extend any class with services related to file-based config

    # ~ section 1 - the actual enhancing of your nerklette

    DSL = MetaHell::DSL_DSL::Constant_Trouble.
      # we run this DSL thru the user and then we have the application's
      # field values stored in the below constants of its `Service` subclass
      # (called `Config_` and stored in the enhanced class itself.)
      new :Config_, self,
        [ :search_start_pathname,
          :default_init_directory,
          :search_num_dirs,
          :filename
        ]  # (what this does is amazing)


    SEARCH_START_PATHNAME_PROC_ = -> { ::Dir.pwd }

    DEFAULT_INIT_DIRECTORY_PROC_ = -> { ::Dir.pwd }

    SEARCH_NUM_DIRS_VALUE_ = 3

    FILENAME_VALUE_ = 'config'

    def self.enhance host, &blk
      _enhance host, true, blk
    end

    def self.imbue host, &blk
      _enhance host, false, blk
    end

    def self._enhance host, publc, blk
      m = :config
      host.method_defined? m and raise "won't clobber existing `#{ m }`"
      DSL.enhance host, blk
      host.send :include, ( publc ? Host_IMs_Public_ : Host_IMs_Private )
      nil
    end

    Host_IMs_ = [ [ :config, -> do
      @config ||= self.class::Config_.new
    end ] ]

    module Host_IMs_Public_
      Host_IMs_.each do |m, f|
        define_method m, &f
      end
    end

    module Host_IMs_Private_
      Host_IMs_.each do |m, f|
        define_method m, &f
        private m
      end
    end
  end
end
