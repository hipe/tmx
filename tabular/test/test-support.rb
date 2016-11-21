require 'skylab/tabular'
require 'skylab/test_support'

module Skylab::Tabular::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, The_method_called_use___
      NIL
    end
  end  # >>

  Home_ = ::Skylab::Tabular
  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # -

    The_method_called_use___ = -> do

      say = -> sym_ do
        "do this right (like your siblings) - not defined IN THIS FILE - #{ sym_ }"
      end

      cache = {}

      -> sym do

        _callable = cache.fetch sym do

          sym_ = sym.capitalize

          TS_.const_defined? sym_, false or fail say[ sym_ ]

          x = TS_.const_get sym_, false
          cache[ sym ] = x
          x
        end

        _callable[ self ]
        NIL
      end
    end.call
  # -

  # -

    if false  # while #open [#002]
    def subject_
      Home_::CLI_Support::Table::Actor
    end

    def common_args_
      [ :write_lines_to, write_lines_to_, :left, EMPTY_S_, :right, EMPTY_S_ ]
    end

    def write_lines_to_
      @_y ||= []
    end

    def gets_
      @_d ||= -1
      @_d += 1
      @_y.fetch @_d
    end

    def done_
      ( @_d + 1 ) == @_y.length or fail "extra line"
    end
    end

  # -

  # ==
  # -

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

  # -
  # ==

  TS_ = self
end
