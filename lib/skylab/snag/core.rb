require_relative '..'
require 'skylab/callback/core'

module Skylab::Snag

  Callback_ = ::Skylab::Callback

  class << self

    def lib_
      @lib ||= Snag_::Lib_::INSTANCE
    end

    define_method :models_cls, ( Callback_.memoize do

      # go deep into [cb] API

      Models_Hub__.define_reader_methods_via_entry_tree_stream_(
        Models.entry_tree.to_stream )

      Models_Hub__
    end )
  end  # >>

  class Models_Hub__

    class << self

      def define_reader_methods_via_entry_tree_stream_ st

        normpath = st.gets
        while normpath
          sym = normpath.name_symbol
          define_method :"#{ sym }s", bld_module_reader( sym )
          normpath = st.gets
        end

        nil
      end

    private

      def bld_module_reader name_symbol
        -> & p do
          p and raise ::ArgumentError  # #todo remove
          @cache_h.fetch name_symbol do
            silo = bld_shell name_symbol
            silo and @cache_h[ name_symbol ] = silo
          end
        end
      end
    end  # >>

    def initialize invocation_context
      @cache_h = {}
      @invo_ctx = invocation_context
    end

    # names of { public | protected | private } methods must never end in 's'

  private

    def bld_shell name_symbol

      _models_module = @invo_ctx.application_module::Models

      _cls = Autoloader_.const_reduce [ name_symbol ], _models_module

      _cls::Silo_Daemon.new @invo_ctx, :_one_day_etc_
    end
  end

  Autoloader_ = Callback_::Autoloader

  module Core
    Autoloader_[ self ]
  end

  module Models
    Autoloader_[ self, :boxxy ]
  end

  NF_ = -> do
    Bzn__[].name_library
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Event_ = -> { Snag_::Model_::Event }
  IDENTITY_ = -> x { x }
  stowaway :Lib_, 'library-'
  LINE_SEP_ = "\n".freeze
  KEEP_PARSING_ = true
  NEUTRAL_ = nil
  Snag_ = self
  SPACE_ = ' '.freeze
  UNABLE_ = false
end
