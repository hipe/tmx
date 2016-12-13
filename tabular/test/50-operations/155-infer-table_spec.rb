require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] operations - infer table" do

    TS_[ self ]
    use :memoizer_methods
    use :operation_one_day_operations

    context "strange" do

      it "unknown operation" do
        _lines.first == "unknown operation :strange" || fail
      end

      it "available operations" do
        _lines.last =~ /\Aavailable operations: :/ || fail
      end

      shared_subject :_lines do

        call :strange

        _2_lines = nil
        expect :error, :expression, :parse_error, :unknown_primary do |y|
          _2_lines = y
        end

        expect_result NIL

        _2_lines
      end
    end

    it "ping" do

      call :ping

      expect :info, :expression, :ping do |y|
        y.first == [ "hello from tabular!" ]
      end

      expect_result :_ping_from_tabular_
    end

    it "can't table without a m.t.s" do

      call :infer_table

      expect :error, :expression, :missing_required_parameter do |y|
        y.first.include?( "must have a mixed tuple upstream" ) || fail
      end

      expect_result NIL
    end

    it "double money" do

      _mt_st = _mixed_tuple_stream_via(

        [ "jumanny-fumanny-2", 77, 'thing 1B', 12 ],
        [ "thing-2",           99, 'thing 2B', 16 ],
      )

      call :infer_table, :mixed_tuple_upstream, _mt_st, :width, 47

      finish_by do |op|

        _act_st = op.to_line_stream
        exp = TestSupport_::Expect_Line::Scanner.via_stream _act_st
        exp << "jumanny-fumanny-2  77  +++   thing 1B  12  +++ "
        exp << "thing-2            99  ++++  thing 2B  16  ++++"
        exp.expect_no_more_lines
      end
    end

    it "edge - empty second page" do  # #coverpoint-1-1 - an empty PAGE

      # (this happens in nature if you say `echo "a b\nc d\n" | [..]` -
      #  `echo` appends *another* newline to the end of the string so..)

      _mt_st = _mixed_tuple_stream_via(
        [ "one", "two" ],
        [ "three", "four" ],
        EMPTY_A_,
      )

      call( :infer_table,
        :mixed_tuple_upstream, _mt_st,
        :page_size, 2,  # for #coverpoint-1-1
      )

      finish_by do |op|
        _act_st = op.to_line_stream
        exp = TestSupport_::Expect_Line::Scanner.via_stream _act_st
        exp << "one    two "
        exp << "three  four"
        exp << "           "
        exp.expect_no_more_lines
      end
    end

    it "an \"hourglass\" page" do

      _mt_st = _mixed_tuple_stream_via(
        [ "one", "two" ],
        [ "three" ],
      )

      call( :infer_table,
        :mixed_tuple_upstream, _mt_st,
        :page_size, 3,
        :left_separator, '| ',
        :right_separator, ' |',
        :inner_separator, ' | ',
      )

      finish_by do |op|
        _act_st = op.to_line_stream
        exp = TestSupport_::Expect_Line::Scanner.via_stream _act_st
        exp << "| one   | two |"
        exp << "| three |     |"
        exp.expect_no_more_lines
      end
    end


    def _mixed_tuple_stream_via * a_a
      Stream_[ a_a ]
    end
  end
end
# #history: rewrote ancient [as] test file
