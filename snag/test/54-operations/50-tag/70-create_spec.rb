require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - tag - create" do

    TS_[ self ]
    use :want_event
    use :byte_up_and_downstreams
    use :nodes

    context "(with this manifest)" do

      it "the node identifier must be well-formed" do

        _call :node_identifier, 'ziffy', :tag, :x

        _em = want_not_OK_event :expecting_number

        black_and_white( _em.cached_event_value ).should eql(
          "'node-identifier-number-component' #{
            }must be a non-negative integer, had \"ziffy\"" )

        want_fail
      end

      it "the node identifier's referrant must resolve" do

        _call :node_identifier, '00002', :tag, :x

        _em = want_not_OK_event :component_not_found

        black_and_white( _em.cached_event_value ).should match(
          %r(\Athere is no node "\[#2\]") )

        want_fail
      end

      it "the tag must be well-formed" do

        _call :node_identifier, 3, :tag, 'foo bar'

        _em = want_not_OK_event :invalid_tag_stem

        black_and_white( _em.cached_event_value ).should eql(
          "tag must be alphanumeric separated with dashes - #{
            }invalid tag name: \"#foo bar\"" )

        want_fail
      end

      it "it won't let you add a tag redundantly [#001] 'hi'" do

        _call :node_identifier, 1, :tag, 'hi'

        _em = want_neutral_event :component_already_added

        black_and_white( _em.cached_event_value ).should eql(
          "node [#1] already has tag #hi" )

        want_fail
      end

      it "to [#07] append tag '2014-ok'" do

        _call :node_identifier, 7, :tag, '2014-ok',
          :downstream_reference, downstream_ID_for_output_string_ivar_

        scn = scanner_via_output_string_

        scn.next_line.should eql "[#03] this is three\n"
        scn.next_line.should eql "        zygote\n"
        scn.next_line.should eql "[#07] seven #hello in the middle #hi\n"  # NOTE untouched
        scn.next_line.should eql "             bizmark wee #2014-ok\n"
        scn.next_line.should eql "[#01] this is one #hi\n"
        scn.next_line.should be_nil

        want_noded_ 7
      end

      def _call * x_a, & x_p

        x_a.unshift :tag, :create,
          :upstream_reference,
          Fixture_file_[ :for_tag_create_mani ]

        call_API_via_iambic x_a, & x_p
        NIL_
      end
    end
  end
end
