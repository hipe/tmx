require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI (test test) - want section fail early - pre-order" do

    TS_[ self ]
    use :memoizer_methods

    it "to pre-order stream" do

      _tree = _subject.tree_via :string, _string

      _st = _tree.to_pre_order_stream.map_by do |line_o|
        line_o.x.string
      end

      want_these_lines_in_array_with_trailing_newlines_ _st do |y|
        y << 'head'
        y << '  mouth'
        y << 'body'
        y << '  leg'
      end
    end

    memoize :_string do
      <<-HERE.unindent
        head
          mouth
        body
          leg
      HERE
    end

    memoize :_subject do
      TS_::CLI::Want_Section_Fail_Early
    end
  end
end
