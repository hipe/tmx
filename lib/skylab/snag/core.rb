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

      lib_.brazen::Model.common_action_class
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

    Autoloader_[ self, :boxxy ]
  end

  # ~ support

  module Actor_as_Model_Module_Methods_

    def new_with * x_a, & oes_p
      new_via_iambic x_a, & oes_p
    end

    def new_via_iambic x_a, & oes_p
      new do
        if oes_p
          @on_event_selectively = oes_p
        end
        process_iambic_fully x_a
      end
    end
  end

  Argument_interpreter_via_normalization_ = -> n11n do

    -> arg_st, & x_p do

      _trio = Callback_::Trio.new arg_st.gets_one, true

      n11n.normalize_argument _trio do | * i_a, & ev_p |

        if x_p
          x_p[ * i_a, & ev_p ]
        else
          raise ev_p[].to_exception
        end
      end
    end
  end

  module Expression_Methods_

    def description_under expag
      y = expag.new_expression_context
      express_into_under y, expag
      y
    end

    def express_into_under y, expag

      sym = expag.modality_const
      if sym
        _expad_for( sym ).express_into_under_of_ y, expag, self
      else
        express_into_ y
      end
    end

    def express_N_units_into_under d, y, expag

      sym = expag.modality_const
      if sym
        _expad_for( sym ).express_N_units_into_under_of_ d, y, expag, self
      else
        express_N_units_into_under_agnostic_ d, y, exag
      end
    end

    def _expad_for sym

      self.class::Expression_Adapters.const_get sym, false
    end
  end

  INTERPRET_OUT_OF_UNDER_METHOD_ = -> x, moda, & oes_p do

    self::Expression_Adapters.const_get( moda.intern, false ).
      const_get( :Interpret, false )[ x, moda, & oes_p ]
  end

  module Model_
    Autoloader_[ Collection = ::Module.new ]
    Autoloader_[ self ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''
  IDENTITY_ = -> x { x }
  stowaway :Library_, 'lib-'
  LINE_SEP_ = "\n"
  NIL_ = nil
  KEEP_PARSING_ = true
  NEUTRAL_ = nil
  Snag_ = self
  SPACE_ = ' '
  THE_EMPTY_MODULE_ = nil
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
