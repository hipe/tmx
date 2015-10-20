require 'skylab/basic'

module Skylab::Basic

  module TestSupport

    TestSupport_ = Autoloader_.require_sidesystem :TestSupport

    TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

    TestSupport_::Sandbox::Host[ self ]

    extend TestSupport_::Quickie

    module ModuleMethods

      def use sym, * args
        Use_[ args, sym, self ]
      end

      define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

      def memoize_ sym, & p
        define_method sym, ( Callback_.memoize do
          p[]
        end )
      end
    end

    Use_ = -> do

      cache_h = {}

      -> args, sym, tcm do

        ( cache_h.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const, false
            TS_.const_get const, false
          else
            TestSupport_.fancy_lookup sym, TS_
          end

          cache_h[ sym ] = x

          x
        end )[ tcm, * args ]
      end
    end.call

    module InstanceMethods

      def debug!
        @do_debug = true
      end

      attr_reader :do_debug

      def debug_IO
        TestSupport_.debug_IO
      end

      def black_and_white_expression_agent_for_expect_event
        Home_.lib_.brazen::API.expression_agent_instance
      end
    end

    Expect_CLI = -> tcc do
      Home_.lib_.brazen.test_support.CLI::Expect_CLI[ tcc ]
    end

    Expect_Event = -> test_context_class do

      Home_::Callback_.test_support::Expect_Event[ test_context_class ]
    end

    module Expect_Event_Micro

      def self.[] tcc
        tcc.include self ; nil
      end

      def future_expect * a, & p
        _add a, & p
      end

      def future_expect_only * a, & p
        _add a, & p
        future_expect_no_more
      end

      def _add a, & p
        a.push p
        ( @_future_expect_queue ||= [] ).push a
        NIL_
      end

      def future_expect_no_more
        ( @_future_expect_queue ||= [] ).push false
        NIL_
      end

      def fut_p

        st = _future_stream

        -> * i_a, & oes_p do

          if do_debug
            debug_IO.puts "(#{ i_a.inspect })"
          end

          if st.unparsed_exists
            a = st.gets_one
            if a
              p = a.pop
              if a == i_a
                if p
                  p[ oes_p[] ]
                end
              else
                fail "expected #{ a.inspect } had #{ i_a.inspect }"
              end
            else
              fail "expected no more events, had #{ i_a.inspect }"
            end
          else
            # when no unparsed exists and above didn't trigger, ignore event
          end

          false  # if client depends on this, it shouldn't
        end
      end

      def future_is_now

        st = _future_stream
        if st.unparsed_exists
          a = st.gets_one
          if a
            a.pop
            fail "expected #{ a.inspect }, had no more events"
          end
        end
      end

      def _future_stream
        @___future_stream ||= Callback_::Polymorphic_Stream.
          via_array @_future_expect_queue
      end

      Cheap_Event_Record___ = ::Struct.new :category, :event_proc

    end

    String = -> tcc do  # :+#stowaway
      tcc.send :define_method, :subject_module_ do
        Home_::String
      end
    end

    Home_ = ::Skylab::Basic
    Callback_ = Home_::Callback_
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = Home_::EMPTY_S_
    NIL_ = nil

    module Constants
      Home_ = Home_
      Callback_ = Callback_
      TestSupport_ = TestSupport_
    end
  end
end
