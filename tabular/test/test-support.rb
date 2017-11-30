require 'skylab/tabular'
require 'skylab/test_support'

module Skylab::Tabular::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, The_method_called_use___
      tcc.include InstanceMethods___
      NIL
    end
  end  # >>

  Home_ = ::Skylab::Tabular
  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -

    The_method_called_use___ = -> do

      cache = {}

      -> sym do

        _callable = cache.fetch sym do

          const = sym.capitalize

          x = if TS_.const_defined? const, false
            TS_.const_get const, false
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache[ sym ] = x
          x
        end

        _callable[ self ]
        NIL
      end
    end.call
  # -

  module InstanceMethods___

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # ==

  module Operation_one_day_operations

    def self.[] tcc
      Common_.test_support::Want_Emission_Fail_Early[ tcc ]
      tcc.include self
    end

    def expression_agent
      _ = Home_::Zerk_::API::ArgumentScannerExpressionAgent.instance
      _  # #todo
    end

    def subject_API
      Home_::API
    end
  end

  # ==
  # -

    # Operation_one_day_operations  (above)

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

  # -
  # ==

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Common_ = Home_::Common_
  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  Lazy_ = Common_::Lazy
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = nil
  Stream_ = Home_::Stream_
  TS_ = self
end
