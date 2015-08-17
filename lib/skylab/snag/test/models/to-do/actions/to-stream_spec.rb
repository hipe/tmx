require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do - actions - to stream" do

    extend TS_
    use :expect_event, :ignore, :find_command_args

    it "one fine | multiple matches on one line | multiple patterns " do

      call_API :to_do, :to_stream,
        :path, [ Fixture_file_[ :foo_txt ] ],
        :pattern, [ '\<deta\>', '\<geta', 'jeta\>' ]

      st = @result

      x1 = st.gets
      path = x1.path
      ::File.basename( path ).should eql 'foo.txt'

      x2 = st.gets
      x2.path.object_id.should eql path.object_id

      x3 = st.gets
      x3.path.object_id.should eql path.object_id

      st.gets.should be_nil
    end

    it "the name option" do

      call_API :to_do, :to_stream,
        :path, [ Fixture_tree_[ :some_todos ] ],
        :pattern, [ '[%]to-dew\>' ],
        :name, [ '*.code' ]

      st = @result

      o = st.gets
      ::File.basename( o.path ).should eql 'ferbis.code'
      o.lineno.should eql 2

      o = st.gets
      ::File.basename( o.path ).should eql 'one.code'
      o.lineno.should eql 1

      o = st.gets
      ::File.basename( o.path ).should eql 'one.code'
      o.lineno.should eql 3

      st.gets.should be_nil
    end

    it "tries to avoid false matches" do  # but this is not language aware [#068]

      call_API :to_do, :to_stream,
        :path, [ Fixture_file_[ :matched_by_first_but_not_second_phase ] ],
        :pattern, [ '@todo\>' ]

      _st = @result

      _st.gets.should be_nil

      __expect_event_about_did_not_match
    end

    def __expect_event_about_did_not_match

      expect_neutral_event :did_not_match do | ev |

        ev = ev.to_event

        black_and_white( ev ).should match(
          %r(\Askipping a line that matched via `grep`) )

        ev.path[ -6 .. -1 ].should eql '.phase'
        ev.lineno.should eql 2
        ev.line[ -6 .. -1 ].should eql "a tag\n"
      end

      expect_no_more_events
    end
  end
end
