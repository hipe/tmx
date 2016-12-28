require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - node for treemap via recording" do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    it "loads" do
      Home_::Magnetics_::Node_for_Treemap_via_Recording || fail
    end

    context "case zero - first ever use of model" do

      given_request do |o|
        o.head_const = 'Weeble'
      end

      it "builds" do
        treemap_node_ || fail
      end

      it "every non-root child has a short name" do
        expect_every_non_root_child_has_a_short_name_
      end

      it "terminal nodes have weights" do
        expect_every_non_root_terminal_child_has_weights_
      end

      it "root node has an appropriate label string" do
        expect_root_node_has_an_appropriate_label_string_
      end

      shared_subject :treemap_node_ do

        build_treemap_node_via_recording_lines_ do |y|
          y << " 1 class Weeble::Deeble /fliff/flaff\n"
          y << " 3 class Weeble::Deeble::Dopp /fliff/flaff\n"
          y << " 7 end Weeble::Deeble::Dopp /fliff/flaff\n"
          y << " 9 class Weeble::Deeble::Doop /fliff/flaff\n"
          y << "12 end Weeble::Deeble::Doop /fliff/flaff\n"
          y << "14 end Weeble::Deeble /fliff/flaff\n"
        end
      end
    end

    context "case zero.50 - sing classes" do
      # #mon-testpoint-1-1

      given_request do |o|
        o.head_const = 'Weeble'
      end

      it "hm .. for now for pragmatic reasons we'll skip them" do
        _x = treemap_node_
        _st = _x.to_child_stream
        a = _st.to_a
        1 == a.length || fail
        a.fetch(0).label_string == "Deeble" || fail
      end

      shared_subject :treemap_node_ do

        build_treemap_node_via_recording_lines_ do |y|
          y << "  1 class Weeble::Deeble /fliff/flaff\n"
          y << "  6 class «singleton class» /fliff/flaff\n"
          y << " 14 end «singleton class» /fliff/flaff\n"
          y << " 18 class Weeble::Deeble::Momma /fliff/flaff\n"
          y << " 22 end Weeble::Deeble::Momma /fliff/flaff\n"
          y << " 26 end Weeble::Deeble /fliff/flaff\n"
        end
      end
    end

    context "case one - load a real file" do

      it "builds" do
        treemap_node_ || fail
      end

      it "every non-root child has a short name" do
        expect_every_non_root_child_has_a_short_name_
      end

      it "terminal nodes have weights" do
        expect_every_non_root_terminal_child_has_weights_
      end

      it "root node has an appropriate label string" do
        expect_root_node_has_an_appropriate_label_string_
      end

      def treemap_node_
        treemap_node_01_faboozle
      end
    end

    def event_listener_
      NOTHING_
    end
  end
end
