require 'skylab/common'

module Skylab::Snag

  def self.describe_into_under y, _
    y << "exciting experiments in issue tracking simplification"
  end

  module API

    class << self

      def call * x_a, & oes_p

        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  Common_ = ::Skylab::Common

  class << self

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @lib ||= Home_::Lib_.instance
    end

  end  # >>

  Autoloader_ = Common_::Autoloader

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

  _ACS = nil
  ACS_ = -> do
    _ACS ||= Home_.lib_.autonomous_component_system
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

            _slug = Common_::Name.via_const_symbol( first.name_symbol ).as_slug

            _path = ::File.join model_class.dir_path, 'actions', _slug

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

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_= true
  Bsc__ = Autoloader_.build_require_sidesystem_proc :Basic
  Bzn__ = Autoloader_.build_require_sidesystem_proc :Brazen
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''
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
