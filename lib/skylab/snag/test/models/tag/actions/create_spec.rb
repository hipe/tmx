require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - actions - create" do

    extend TS_
    use :expect_event
    use :downstream_redirect_to_string

    context "(with this manifest)" do

      it "the node identifier must be well-formed" do

        _call :node_identifier, 'ziffy', :tag, :x

        _ev = expect_not_OK_event :uninterpretable_under_number_set

        black_and_white( _ev ).should eql(
          "'node-identifier-number-component' #{
            }must be a non-negative integer, had 'ziffy'" )

        expect_failed
      end

      it "the node identifier's referrant must resolve" do

        _call :node_identifier, '00002', :tag, :x

        black_and_white( expect_not_OK_event :entity_not_found ).should match(
          %r(\Athere is no node with identifier \[#2\]) )

        expect_failed
      end

      it "the tag must be well-formed" do

        _call :node_identifier, 3, :tag, 'foo bar'

        black_and_white( expect_not_OK_event :invalid_tag_stem ).should eql(
          "tag must be alphanumeric separated with dashes - #{
            }invalid tag name: '#foo bar'" )

        expect_failed
      end

      it "it won't let you add a tag redundantly [#001] 'hi'" do

        _call :node_identifier, 1, :tag, 'hi'

        _ev = expect_not_OK_event :entity_already_added
        black_and_white( _ev ).should eql "[#1] already has #hi"

        expect_failed
      end

      it "to [#07] append tag '2014-ok'" do

        _call :node_identifier, 7, :tag, '2014-ok',
          :downstream_identifier, downstream_ID_around_input_string_

        scn = scanner_via_output_string_

        scn.next_line.should eql "[#03] this is three\n"
        scn.next_line.should eql "        zygote\n"
        scn.next_line.should eql "[#07] seven #hello in the middle #hi\n"  # NOTE untouched
        scn.next_line.should eql "             bizmark wee #2014-ok\n"
        scn.next_line.should eql "[#01] this is one #hi\n"
        scn.next_line.should be_nil

        expect_succeeded
      end

      def _call * x_a, & x_p

        x_a.unshift :tag, :create,
          :upstream_identifier,
          Fixture_file_[ :for_tag_create_mani ]

        call_API_via_iambic x_a, & x_p
        NIL_
      end
    end
  end
end
