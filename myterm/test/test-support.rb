require 'skylab/myterm'
require 'skylab/test_support'

module Skylab::MyTerm::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      TS_.__lib( sym )[ self ]
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def call_ * x_a, & custom_p

      _oes_p = if custom_p
        custom_p
      else
        fut_p  # assumes future expect for now
      end

      bc = subject_kernel_.bound_call_via_mutable_iambic x_a, & _oes_p

      if bc

        @result = bc.receiver.send bc.method_name, * bc.args, & bc.block

        future_is_now  # assert no unexpected events
      else
        fail __say_failed_to_make_bound_call x_a
      end

      NIL_
    end

    def __say_failed_to_make_bound_call x_a
      "bound call failed to #{ x_a[ 0, 2 ].inspect } (turn debugging on)"
    end

    def subject_kernel_
      # use this real kernel for read-only type operations.
      Home_.application_kernel_
    end
  end

  class << self

    h = {}
    define_method :__lib do | sym |

      h.fetch sym do

        s = sym.id2name
        const = "#{ s[ 0 ].upcase }#{ s[ 1..-1 ] }".intern

        x = if TestLib_.const_defined? const, false
          TestLib_.const_get const, false
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        h[ sym ] = x
        x
      end
    end
  end  # >>

  module TestLib_

    Danger_memo = -> tcc do

      tcc.send :define_singleton_method,
        :dangerous_memoize_,
        TestSupport_::DANGEROUS_MEMOIZE
    end

    Future_expect = -> tcc do  # test context class
      Callback_.test_support::Future_Expect[ tcc ]
    end
  end

  Callback_ = ::Skylab::Callback
  Home_ = ::Skylab::MyTerm
  NIL_ = nil
end
