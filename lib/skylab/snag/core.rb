require_relative '..'
require 'skylab/callback/core'

module Skylab::Snag

  module CLI

    class << self

      def new * a

        Snag_.lib_.brazen::CLI.new_top_invocation a, Snag_.application_kernel_
      end
    end  # >>

    # ~ begin :+#hook-out for tmx
    Client = self
    module Adapter
      module For
        module Face
          module Of
            Hot = -> x, x_ do
              Snag_.lib_.brazen::CLI::Client.fml Snag_, x, x_
            end
          end
        end
      end
    end
    # ~ end
  end

  module API

    class << self

      def call * x_a, & oes_p

        bc = Snag_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  Callback_ = ::Skylab::Callback

  class << self

    def action_class  # #hook-out for procs as actions (for name stop index)

      lib_.brazen.model.action_class
    end

    define_method :application_kernel_, ( Callback_.memoize do
      Snag_.lib_.brazen::Kernel.new Snag_
    end )

    def lib_
      @lib ||= Snag_::Lib_.instance
    end

  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Models_

    Ping = -> act_pxy, & oes_p do

      oes_p.call :info, :expression, :ping do | y |
        y << "hello from #{ act_pxy.kernel.app_name }."
      end

      :hello_from_snag
    end

    Tag_Collection = :NO  # #todo:near-step:11

    Autoloader_[ self, :boxxy ]
  end

  EXPRESS_INTO_UNDER_ = -> y, expag do

    self.class::Expression_Adapters.const_get( expag.modality_const, false ).
      express_into_under_of_ y, expag, self
  end

  module Expression_Methods_

    def express_into_under y, expag

      _expad_for( expag ).express_into_under_of_ y, expag, self
    end

    def express_N_units_into_under d, y, expag

      _expad_for( expag ).express_N_units_into_under_of_ d, y, expag, self
    end

    def _expad_for expag
      self.class::Expression_Adapters.const_get expag.modality_const, false
    end
  end

  INTERPRET_OUT_OF_UNDER_METHOD_ = -> x, moda, & oes_p do

    self::Expression_Adapters.const_get( moda.intern, false ).

      interpret_out_of_under_ x, moda, & oes_p
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }
  stowaway :Library_, 'lib-'
  LINE_SEP_ = "\n".freeze
  NIL_ = nil
  KEEP_PARSING_ = true
  NEUTRAL_ = nil
  Snag_ = self
  SPACE_ = ' '.freeze
  THE_EMPTY_MODULE_ = ::Module.new.freeze
  UNABLE_ = false
end
