if false
require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - table - actor - stats" do

    TS_[ self ]
    use :CLI_support_table_actor

    _SUBJECT_SYMBOL = :gather_statistics

    it "minimal example of a formula" do

      subject_[

        :left, '( ', :right, ' )', :sep, ' - ',

        :header, :none,

        :field,
          _SUBJECT_SYMBOL,

        :field,
          :formula,
          -> row, cols do

            1.0 * row[ 0 ] / cols.column_at( 0 )[ :stats ].numeric_max
          end,

        :read_rows_from,
          [ [ 1, nil ],
            [ 2, nil ] ],

        :write_lines_to, write_lines_to_,
      ]

      _expect "( 1 - 0.5 )"
      _expect "( 2 - 1.0 )"
      done_
    end
  end
end
# #history: tests related to type inference corralled into sibling file
end
