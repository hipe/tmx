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

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Common_ = Home_::Common_
  Lazy_ = Common_::Lazy
  NOTHING_ = nil
  Stream_ = Home_::Stream_
  TS_ = self
end
