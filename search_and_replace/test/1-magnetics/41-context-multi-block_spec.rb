require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (41) context multi-block" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_DSL

    context "several blocks, one match" do

      shared_input_ do

        input_string unindent_ <<-HERE
          line 1
          line 2
          ohai
          line 4
          line 5
        HERE

        regexp %r(^ohai$)
      end

      context "don't engage the replacement" do

        shared_subject :edit_session_ do

          build_edit_session_
        end

        it "(the replacement looks good)" do

          expect_output_ edit_session_, unindent_( <<-HERE )
            line 1
            line 2
            ohai
            line 4
            line 5
          HERE
        end

        context "ask for no leading and no trailing context" do

          shared_subject :tuple_ do
            _tuple_via 0, 0
          end

          it "before lines is none" do
            _before_is_none
          end

          it "after lines is none" do
            _after_is_none
          end

          it "during is legit" do
            _during_is_legit
          end
        end

        context "ask for one trailing no leading" do

          shared_subject :tuple_ do
            _tuple_via 0, 1
          end

          it "before is none" do
            _before_is_none
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is legit" do
            _after_is_legit
          end
        end

        context "ask for one leading no trailing" do

          shared_subject :tuple_ do
            _tuple_via 1, 0
          end

          it "before is legit" do
            _before_is_legit
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is none" do
            _after_is_none
          end
        end

        def _during_is_legit
          one_line_( lines_during_ ).should eql "ohai\n"
        end
      end

      context "do engage the replacement" do

        shared_subject :edit_session_ do

          es = build_edit_session_
          mc = es.first_match_controller
          mc.engage_replacement_via_string 'yerp'
          es
        end

        it "(the replacement looks good)" do

          expect_output_ edit_session_, unindent_( <<-HERE )
            line 1
            line 2
            yerp
            line 4
            line 5
          HERE
        end

        context "ask for one leading and one trailing" do

          shared_subject :tuple_ do
            _tuple_via 1, 1
          end

          it "before is legit" do
            _before_is_legit
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is legit" do
            _after_is_legit
          end
        end

        def _during_is_legit
          one_line_( lines_during_ ).should eql "yerp\n"
        end
      end

      def _before_is_none
        lines_before_.should be_nil
      end

      def _after_is_none
        lines_after_.should be_nil
      end

      def _before_is_legit
        one_line_( lines_before_ ).should eql "line 2\n"
      end

      def _after_is_legit
        one_line_( lines_after_ ).should eql "line 4\n"
      end

      def _tuple_via num_before, num_after

        _es = edit_session_
        _mc = _es.first_match_controller
        _mc.to_contextualized_sexp_line_streams num_before, num_after
      end
    end
  end
end
