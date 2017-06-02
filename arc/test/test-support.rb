require 'skylab/arc'
require 'skylab/test_support'

module Skylab::Arc::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

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

    def state_for_expect_emission
      root_ACS_state
    end

    def call_ * x_a

      if block_given?
        self._WRITE_ME
      end

      _cls = subject_root_ACS_class

      root = _cls.new_cold_root_ACS_for_expect_root_ACS

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

    # --

    def expag_for_modernity_
      Autoloader_.require_sidesystem( :Zerk )::No_deps[]::API_InterfaceExpressionAgent.instance
    end

    def expag_for_cleanliness_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def expag_for_codifying__
      Common_::Event.codifying_expression_agent_instance
    end

    # --

    def build_root_ACS  # build cold root
      subject_root_ACS_class.new_cold_root_ACS_for_expect_root_ACS
    end
  end

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  # -- fixtures & mocks

  Fixture_top_ACS_class = -> const do
    Fixture_Top_ACS_Classes.const_get const, false
  end

  NODE_PATH__ = ::File.dirname __FILE__

  module Fixture_Top_ACS_Classes

    class Class_01_Empty

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        private :new
      end  # >>

      def initialize & oes_p
        @_IGNORED_EVENT_HANDLER = true
      end

      def hello
        :_emtpy_guy_
      end
    end

    Class_91_Trueish = -> st do
      x = st.gets_one
      if x
        Common_::KnownKnown[ x ]
      else
        self._NOT_NEEDED_YET
      end
    end

    rx_92 = nil
    Class_92_Normal_Primitive_Lemma = -> st, & pp do
      rx_92 ||= /\A[a-z]+\z/
      s = st.head_as_is
      if rx_92 =~ s
        st.advance_one
        Common_::KnownKnown[ s ]
      else
        _oes_p = pp[ nil ]
        _oes_p.call :error, :expression, :nope do |y|
          y << "(must be a lowercase word (had: #{ ick s }).)"
          y << "so i guess that's that."
        end
        UNABLE_
      end
    end

    Autoloader_[ self, ::File.join( NODE_PATH__, 'fixture-top-ACS-classes' ) ]
      # (a.l will no longer infer paths if they have any uppercase letters.
      #  we have "grandfathered" in the above rather than renaming the dir.)

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

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  No_events_ = -> * i_a, & ev_p do
    fail "unexpected: #{ i_a.inspect }"
  end

  No_events_pp_ = -> _ do
    fail "no."
  end

  module TestLib_

    Expect_event = -> tcc do
      Common_.test_support::Expect_Emission[ tcc ]
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Autoloader_[ self, NODE_PATH__ ]

  ACHIEVED_ = true
  Home_ = ::Skylab::Arc
  EMPTY_S_ = ''
  NIL_ = nil
  TS_ = self
  UNABLE_ = false
end
