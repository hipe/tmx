module Skylab::TMX::TestSupport

  module Operations

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def call_by & p

        yes = true ; x = nil
        define_method :operations_call_result_tuple do
          if yes
            yes = false
            x = __produce_operations_call_result_tuple p
          end
          x
        end
      end

      def expect_no_events
        define_method :_build_event_log_for_operations do
          NOTHING_
        end
      end
    end

    # ==

    module InstanceMethods___

      # -- expectations

      def fails
        _tu = operations_call_result_tuple
        _x = _tu.result
        if false != _x
          _x.should eql false
        end
      end

      def expect_parse_error_emission_

        em = only_emission
        em.channel_symbol_array[ 2 ] == :parse_error || fail
        em
      end

      def only_emission
        _tu = operations_call_result_tuple
        em_a = _tu.emission_array
        if 1 == em_a.length
          em_a.fetch 0
        else
          em_a.length.should eql 1
        end
      end

      # -- setup & support

      def __produce_operations_call_result_tuple p
        @operations_call_DSL_tuple = DSL_Values___.new
        instance_exec( & p )
        o = remove_instance_variable :@operations_call_DSL_tuple
        el = _build_event_log_for_operations
        if el
          _p = el.handle_event_selectively
        end
        _x = Home_::API.call( * o.arguments_array, & _p )
        if el
          _em_a = el.release_to_mutable_array
        end
        CallResult____.new _em_a, _x
      end

      def call * x_a
        @operations_call_DSL_tuple.arguments_array = x_a ; nil
      end

      def _build_event_log_for_operations
        Common_.test_support::Expect_Event::EventLog.for self
      end

      def expect_event_debugging_expression_agent
        Zerk_[]::API::ArgumentScannerExpressionAgent.instance
      end

      alias_method :expag_, :expect_event_debugging_expression_agent
    end

    # ==

    CallResult____ = ::Struct.new :emission_array, :result
    DSL_Values___ = ::Struct.new :arguments_array

    # === LEGACY ([br]) BELOW

    if false
    Reactions = -> tcc do
      Common_.test_support::Expect_Event[ tcc ]
      Building[ tcc ]
    end

    # <-

  module Building

    def self.[] tcc
      tcc.include self
    end

    def build_and_call_ * x_a

      block_given? and self._NOT_YET

      _o = front_
      @result = _o.call( * x_a, & event_log.handle_event_selectively )
      NIL_
    end

    def build_mock_unbound_ sym
      TS_::Mocks::Unbound.new sym
    end

    define_method :build_shanoozle_into_ do | mod |

      # into the argument module build what is needed to make it a minimal
      # reactive model host, complete with one action and a running kernel

      bz = Home_.lib_.brazen

      mod::Models_ = ::Module.new  # (before next)

      mod::API = ::Module.new
      mod::API.send :define_singleton_method, :application_kernel_, -> do
        ak = bz::Kernel.new mod
        -> do
          ak
        end
      end.call

      model = ::Module.new

      mod::Models_::No_See = model

      model::Actions = ::Module.new

      cls = ::Class.new bz::Action

      model::Actions::Shanoozle = cls

      cls.is_promoted = true

      cls
    end

    def subject_module_
      Home_::Models_::Reactive_Model_Dispatcher
    end

    def init_front_with_box_ fr, bx

      fr.fast_lookup = -> nf do
        bx[ nf.as_lowercase_with_underscores_symbol ]
      end

      fr.unbound_stream_builder = -> do
        bx.to_value_stream
      end
      NIL_
    end
  end
    end  # if false
# ->
  end
end
