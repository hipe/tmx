require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - line ranges - model" do

    TS_[ self ]
    use :quickie
    use :quickie_indicated_line_ranges

    # (there are so many permutations of line ranges that can fail that
    # we cover them (all?) with dedicated "unit"-style tests here.)

    it "loads" do
      subject_class_ || fail
    end

    it "you can't have the same line number twice" do

      line 3
      line 3

      expect_fail do |y|
        y << "'line' 3 overlaps with existing 'line' 3. #{
          }combine these ranges."
      end
    end

    it "you can't have an upside-down range" do

      from_to 2, 1

      expect_fail :upsidedown_range do |y|
        y << "'to' must be greater than 'from'"
        y << "(had from: 2 and to: 1)"
      end
    end

    it "you can't even have a range that is from X to X - use line" do

      from_to 3, 3

      expect_fail :upsidedown_range do |y|
        y << "'to' must be greater than 'from'"
        y << "(had from: 3 and to: 3)"
      end
    end

    it "you can't have a range that overlaps with another range" do

      from_to 3, 7
      from_to 5, 9

      expect_fail do |y|
        y << "range 'from' 5 'to' 9 overlaps with existing range #{
          }'from' 3 'to' 7. combine these ranges."
      end
    end

    it "you can't leave a dangling 'from'" do

      from 7
      from 10

      expect_fail :bad_sequence do |y|
        y << "'from' cannot follow unclosed 'from'"
      end
    end

    it "(same but line)" do

      from 7
      line 10

      expect_fail :bad_sequence do |y|
        y << "'line' cannot follow unclosed 'from'"
      end
    end

    it "you can't have two `to`'s in a row" do

      to 7
      to 10

      expect_fail do |y|
        y << "range 'from' 1 'to' 10 #{
          }overlaps with existing range 'from' 1 'to' 7. combine these ranges."
      end
    end

    it "ranges out of order with respect to each other are OK" do

      from_to 9, 10
      from_to 3, 7

      expect_succeed
    end

    it "ranges in order with respect to each other are OK" do

      from_to 3, 7
      line 9
      from_to 11, 12

      expect_succeed
    end

    it "but you can't have a range kissing another range (encourage normal input)" do

      from_to 10, 12
      from_to 7, 9

      expect_fail do |y|
        y << "range 'from' 7 'to' 9 kisses existing range 'from' 10 'to' 12. #{
          }combine these ranges."
      end
    end

    it "(same with line)" do

      line 10
      from_to 7, 9

      expect_fail do |y|
        y << "range 'from' 7 'to' 9 kisses existing 'line' 10. #{
          }combine these ranges."
      end
    end

    it "low high middle overlap early (edge)" do

      from_to 4, 6
      line 10
      from_to 5, 8

      expect_fail do |y|
        y << "range 'from' 5 'to' 8 overlaps with existing range 'from' 4 'to' 6. #{
          }combine these ranges."
      end
    end

    it "low high middle kiss early (edge)" do

      from_to 4, 6
      line 10
      from_to 7, 8

      expect_fail do |y|
        y << "range 'from' 7 'to' 8 kisses existing range 'from' 4 'to' 6. #{
          }combine these ranges."
      end
    end

    it "low high middle overlap late (edge)" do

      from_to 4, 6
      from_to 10, 12
      from_to 8, 11

      expect_fail do |y|
        y << "range 'from' 8 'to' 11 overlaps with existing range 'from' 10 'to' 12. #{
          }combine these ranges."
      end
    end

    it "low high middle kiss late (edge)" do

      from_to 4, 6
      from_to 10, 12
      from_to 8, 9

      expect_fail do |y|
        y << "range 'from' 8 'to' 9 kisses existing range 'from' 10 'to' 12. #{
          }combine these ranges."
      end
    end

    it "low high middle OK" do

      from_to 4, 6
      line 10
      line 8

      expect_succeed
    end

    def expression_agent

      # (using the API expag costs one more file load than using the CLI
      # expag, but the rendered messages read better in tests..)

      # subject_module_::CLI_ExpressionAgent___.instance

      subject_module_::API::ExpressionAgent.instance
    end
  end
end
# #born
