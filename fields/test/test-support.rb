require 'skylab/fields'
require 'skylab/test_support'

module Skylab::Fields::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  -> do

    cache = {}

    lookup = -> k do

      const = Common_::Name.via_variegated_symbol( k ).as_const

      if TS_.const_defined? const, false
        TS_.const_get const
      else
        TestSupport_.fancy_lookup k, TS_
      end
    end

    define_singleton_method :require_ do |k|
      cache.fetch k do
        x = lookup[ k ]
        cache[ k ] = x
        x
      end
    end

  end.call

  module ModuleMethods___

    def use k
      TS_.require_( k )[ self ]
    end

    def subject & p
      memoize_ :subject, & p
    end

    def memoize_ sym, & p
      define_method sym, Common_.memoize( & p )
    end

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE
  end

  Expect_missinger_ = -> noun_lemma, yes_newline=nil do

    # produces a function that assists in the definitions for the methods
    # called `expect_missing_required_message_with_newline_` etc ick/meh

    -> msg, sym_a, tc do

      _ = sym_a.map do |s|
        "'#{ s }'"
      end.join " and "  # ..

      expected_s = "missing required #{ noun_lemma }#{ 's' if 1 != sym_a.length } #{ _ }#{ yes_newline }"

      if msg != expected_s
        msg.should tc.eql expected_s
      end
    end
  end

  module InstanceMethods___

    def black_and_white_line_via_event_ ev
      a = black_and_white_lines_via_event_ ev
      1 == a.length || fail
      a[0]
    end

    def black_and_white_lines_via_event_ ev
      _expag = Zerk_lib_[]::No_deps[]::API_InterfaceExpressionAgent.instance
      _lines = ev.express_into_under [], _expag
      _lines  # hi. #todo
    end

    def expect_these_lines_in_array_ a, & p
      TestSupport_::Expect_these_lines_in_array[ a, p, self ]
    end

    def my_all_purpose_expression_agent_

      MY_ALL_PURPOSE_EXPRESSION_AGENT___
    end

    # ~ :[#007.E] we might go indifferent to false or nil here but not sure

    def expect_this_one_false_or_nil_NOT_USED_ x
      _expect_false_or_nil_TS x, nil
    end

    def expect_this_other_false_or_nil_ x
      _expect_false_or_nil_TS x, false
    end

    def _expect_false_or_nil_TS act, exp
      if act != exp
        _ = if act
          "<##{ act.class }>"
        else
          act.inspect
        end
        fail "expected #{ exp.inspect }, had #{ _ }"
      end
    end

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

    def state_for_expect_emission
      state_
    end
  end

  # ==

  module MY_ALL_PURPOSE_EXPRESSION_AGENT___ ; class << self

    # (writing our own just to get a sense for what is called by whom)

    alias_method :calculate, :instance_exec

    def ick x
      "«ick: #{ x }»"
    end

    def par prp
      "«prp: #{ prp.name_symbol }»"
    end

    def val x
      "«val: #{ x }»"
    end

    def nm name
      # "«nm: #{ name.as_slug }»"  too painful
      "'#{ name.as_slug }'"
    end

  end ; end

  # --

  Build_next_integer_generator_starting_after = -> d do

    -> do
      d += 1
    end
  end

  # --

  Home_ = ::Skylab::Fields
  Autoloader_ = Home_::Autoloader_
  Common_ = Home_::Common_
  Lazy_ = Home_::Lazy_

  # --

  module Common_Frame  # #stowaway
    class << self
      def lib
        Home_::Stack::CommonFrame
      end
      def definition_for_etc  # `expect_missing_required_message_without_newline_`
        @___etc ||= __etc
      end
      def __etc
        p = Expect_missinger_[ 'field' ]
        -> msg, * sym_a do
          p[ msg, sym_a, self ]
        end
      end
    end  # >>
  end

  # --

  Expect_Emission_Fail_Early = -> tcc do

    Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
  end

  Expect_Event = -> tcm do

    Common_.test_support::Expect_Emission[ tcm ]
  end

  Memoizer_Methods = -> tcc do

    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Zerk_lib_ = Lazy_.call do  # it would be eew to need this in production
    Autoloader_.require_sidesystem :Zerk
  end

  Parse_lib_ = Lazy_.call do  # 1x
    Autoloader_.require_sidesystem :Parse
  end

  # --

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  KEEP_PARSING_ = true
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n"
  NIL_ = nil
  Scanner_ = Home_::Scanner_
  TS_ = self
end

Skylab::TestSupport::Quickie.enable_kernel_describe  # for > 10 legacy files
