require 'skylab/tabular'
require 'skylab/test_support'

module Skylab::Tabular::TestSupport

  Home_ = ::Skylab::Tabular
  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

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
end
