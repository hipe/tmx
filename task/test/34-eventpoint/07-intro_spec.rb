require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] eventpoint - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :eventpoint

    it "library loads" do
      subject_module_ || fail
    end

    it "try to build a graph with invalid references" do

      begin
        subject_module_.define_graph do |o|
          o.beginning_state :begnio
          o.add_state :chumba, :can_transition_to, :wumba
          o.add_state :begino, :can_transition_to, :chumba
        end
      rescue subject_module_::KeyError => e
      end

      e.message == "unresolved reference: wumba" || fail
    end

    context "a graph with three nodes" do

      it "builds" do
        _subject || fail
      end

      shared_subject :_subject do

        subject_module_.define_graph do |o|

          o.beginning_state :beginning

          o.add_state :beginning,
            :can_transition_to, [ :middle, :ending ]

          o.add_state :middle,
            :can_transition_to, :ending

          o.add_state :ending
        end
      end

      it "to dot forwardsly" do

        _st = _subject.to_line_stream_for_dot_file

        _exp = <<-HERE.unindent
          digraph {
            beginning -> middle
            beginning -> ending
            middle -> ending
          }
        HERE

        _expect_same_lines _st, _exp
      end

      it "oh look a graph (it did the inversion)" do

        _st = _subject.to_line_stream_for_dot_file_inverted

        _exp = <<-HERE.unindent
          digraph {
            middle -> beginning
            ending -> beginning
            ending -> middle
          }
        HERE

        _expect_same_lines _st, _exp
      end

      def _expect_same_lines exp_x, act_x
        TestSupport_::Expect_Line::Expect_same_lines[ exp_x, act_x, self ]
      end
    end
  end
end
# #history: same spirit of tests with full rewrite
