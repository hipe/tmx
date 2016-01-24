require 'skylab/autonomous_component_system'
require 'skylab/test_support'

module Skylab::Autonomous_Component_System::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  class << self

    def [] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end
  end  # >>

  define_singleton_method :lib, -> do

    cache_h = {}

    -> sym do
      cache_h.fetch sym do

        s = sym.id2name
        const = :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
        x = if TestLib_.const_defined? const, false
          TestLib_.const_get const
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        cache_h[ sym ] = x
        x
      end
    end
  end.call

  module Module_Methods___

    def use sym
      TS_.lib( sym )[ self ]
    end

    def call_by_ & p

      dangerous_memoize :root_ACS_state do
        instance_exec( & p )
        _o = remove_instance_variable :@root_ACS
        _x = remove_instance_variable :@result
        root_ACS_state_via _x, _o
      end
    end
  end

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # --

    TestSupport_::Memoization_and_subject_sharing[ self ]

    memoize :_EMPTY_JSON_LINES do
      [ "{}\n" ]
    end

    def state_  # nasty: for expect_event & expect_root_ACS when together
      root_ACS_state
    end

    def call_ * x_a

      if block_given?
        self._WRITE_ME
      end

      root = subject_root_ACS_class.new_

      oes_p = event_log.handle_event_selectively

      _oes_p_p = -> _ do
        oes_p
      end

      @result = Home_.edit x_a, root, & _oes_p_p
      @root_ACS = root

      NIL_
    end

    def const_ sym
      subject_root_ACS_class.const_get( sym, false )
    end
  end

  Callback_ = ::Skylab::Callback
  Autoloader__ = Callback_::Autoloader

  # -- fixtures & mocks

  Fixture_top_ACS_class = -> const do
    Fixture_Top_ACS_Classes.const_get const, false
  end

  module Fixture_Top_ACS_Classes

    class Class_01_Empty

      def initialize & oes_p
        @_IGNORED_EVENT_HANDLER = true
      end

      def hello
        :_emtpy_guy_
      end
    end

    Autoloader__[ self ]
    Here_ = self
  end

  Be_compound = -> cls do
    cls.class_exec do
      def self.interpret_compound_component p
        p[ new ]
      end
    end
  end

  Be_component = -> cls do
    cls.class_exec do
      def self.interpret_component st, & pp
        new st, & pp
      end
    end
  end

  # --

  No_events_ = -> * i_a, & ev_p do
    fail "unexpected: #{ i_a.inspect }"
  end

  No_events_pp_ = -> _ do
    fail "no."
  end

  module TestLib_

    Expect_event = -> tcc do
      Callback_.test_support::Expect_Event[ tcc ]
    end

    Future_expect = -> tcc do
      Callback_.test_support::Future_Expect[ tcc ]
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Home_ = ::Skylab::Autonomous_Component_System
  EMPTY_S_ = ''
  NIL_ = nil
  TS_ = self
  UNABLE_ = false
end
