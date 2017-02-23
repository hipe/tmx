require 'skylab/basic'

module Skylab::Basic

  module TestSupport

    class << self
      def [] tcc
        tcc.extend ModuleMethods___
        tcc.include InstanceMethods___
      end
    end  # >>

    TestSupport_ = Autoloader_.require_sidesystem :TestSupport

    TestSupport_::Quickie.
      enhance_test_support_module_with_the_method_called_describe self

    module ModuleMethods___

      def use sym, * args
        Use_[ args, sym, self ]
      end

      define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

      def memoize_ sym, & p
        define_method sym, ( Common_.memoize do
          p[]
        end )
      end
    end

    Use_ = -> do

      cache_h = {}

      -> args, sym, tcm do

        ( cache_h.fetch sym do

          const = Common_::Name.via_variegated_symbol( sym ).as_const

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

    module InstanceMethods___

      def debug!
        @do_debug = true
      end

      attr_reader :do_debug

      def debug_IO
        TestSupport_.debug_IO
      end

      def handle_event_selectively_
        event_log.handle_event_selectively
      end

      def expect_errored_with_ sym, msg=nil

        em = expect_errored_with nil, msg
        em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
        em
      end

      def expect_not_OK_event_ sym, msg=nil

        em = expect_not_OK_event nil, msg
        em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
        em
      end

      def expect_event_ sym

        em = expect_event
        em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
        em
      end

      def subject_API_value_of_failure
        FALSE
      end
    end

    # --

    module Word_Wrapper_Calm  # #stowaway

      def self.[] tcc
        tcc.include self
      end

      def subject_via_ *x_a
        subject_module_.call_via_iambic x_a
      end

      def subject_with_ *x_a
        subject_module_.via_iambic x_a
      end

      def subject_module_
        Home_::String::WordWrapper::Calm
      end
    end

    # --

    Expect_CLI = -> tcc do
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
    end

    Expect_Event = -> test_context_class do

      Home_::Common_.test_support::Expect_Emission[ test_context_class ]
    end

    Future_Expect = -> tcc do

      Home_::Common_.test_support::Expect_Emission_Fail_Early::Legacy[ tcc ]
    end

    Memoizer_Methods = -> tcc do

      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

    Stream_ = -> a, & p do
      Home_::Common_::Stream.via_nonsparse_array a, & p
    end

    String = -> tcc do  # :+#stowaway
      tcc.send :define_method, :subject_module_ do
        Home_::String
      end
    end

    The_Method_Called_Let = -> tcc do
      TestSupport_::Let[ tcc ]
    end

    Home_ = ::Skylab::Basic

    Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

    Common_ = Home_::Common_
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = Home_::EMPTY_S_
    NIL_ = nil
    NOTHING_ = nil
    TS_ = self

    module Constants
      Home_ = Home_
      Common_ = Common_
      TestSupport_ = TestSupport_
    end
  end
end
