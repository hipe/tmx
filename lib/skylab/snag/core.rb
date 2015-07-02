require_relative '..'
require 'skylab/callback/core'

module Skylab::Snag

  module API

    class << self

      def call * x_a, & oes_p

        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  Callback_ = ::Skylab::Callback

  class << self

    def action_base_class  # #hook-out for procs as actions (for name stop index)

      lib_.brazen::Model.common_action_class
    end

    define_method :application_kernel_, ( Callback_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @lib ||= Home_::Lib_.instance
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

      _trio = Callback_::Known.new_known arg_st.gets_one

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
        expad_for_( sym ).express_into_under_of_ y, expag, self
      else
        express_into_ y
      end
    end

    def express_N_units_into_under d, y, expag

      sym = expag.modality_const
      if sym
        expad_for_( sym ).express_N_units_into_under_of_ d, y, expag, self
      else
        express_N_units_into_under_agnostic_ d, y, exag
      end
    end

    def expad_for_ sym

      self.class::Expression_Adapters.const_get sym, false
    end
  end

  INTERPRET_OUT_OF_UNDER_METHOD_ = -> x, moda, & oes_p do

    self::Expression_Adapters.const_get( moda.intern, false ).
      const_get( :Interpret, false )[ x, moda, & oes_p ]
  end

  Make_action_loader_ = -> do  # this is [#006]:[#026]

    p = -> do

      class Actn_Ldr____ < Home_.lib_.brazen::Action

        class << self

          def make
            ::Class.new self
          end

          alias_method :orig_new, :new

          def new( * a, & x_p )

            singleton_class.send :undef_method, :new
            __load
            new( * a, & x_p )
          end

          def is_actionable
            true
          end

          def is_promoted
            false
          end

          def __load

            mod = Home_.lib_.basic::Module

            chain = mod.chain_via_module self
            first = chain.pop
            chain.pop

            model_class = chain.last.value_x

            _slug = Callback_::Name.via_const( first.name_symbol ).as_slug
            _path = model_class.dir_pathname.join( 'actions', _slug ).to_path

            require _path

            singleton_class.send :alias_method, :new, :orig_new

            NIL_
          end
        end  # >>
      end

      p = -> do
        Actn_Ldr____.make
      end

      p[]
    end

    -> do
      p[]
    end
  end.call

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
  MONADIC_EMPTINESS_ = -> _ { }
  NEUTRAL_ = nil
  NEWLINE_ = "\n"
  Home_ = self
  SPACE_ = ' '
  THE_EMPTY_MODULE_ = nil
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
