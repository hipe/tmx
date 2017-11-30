require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] to-do - to stream" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event, :ignore, :find_command_args

    it "one fine | multiple matches on one line | multiple patterns " do

      # #lends-coverage to [#pl-008.5] (along the way)
      # #lends-coverage to [#sn-008.13]

      call_API(
        :to_do, :to_stream,
        :path, Fixture_file_[ :foo_txt ],
        :pattern, '\<deta\>', :pattern, '\<geta', :pattern, 'jeta\>',  # #[#007.D]
      )

      st = @result

      x1 = st.gets
      path = x1.path
      expect( ::File.basename path ).to eql 'foo.txt'

      x2 = st.gets
      expect( x2.path.object_id ).to eql path.object_id

      x3 = st.gets
      expect( x3.path.object_id ).to eql path.object_id

      expect( st.gets ).to be_nil
    end

    it "the name option" do

      call_API(
        :to_do, :to_stream,
        :path, Fixture_tree_[ :some_todos ],
        :pattern, '[%]to-dew\>',
        :name, '*.code',
      )

      st = @result

      o = st.gets
      expect( ::File.basename o.path ).to eql 'ferbis.code'
      expect( o.lineno ).to eql 2

      o = st.gets
      expect( ::File.basename o.path ).to eql 'one.code'
      expect( o.lineno ).to eql 1

      o = st.gets
      expect( ::File.basename o.path ).to eql 'one.code'
      expect( o.lineno ).to eql 3

      expect( st.gets ).to be_nil
    end

    it "tries to avoid false matches" do  # but this is not language aware [#068]

      call_API(
        :to_do, :to_stream,
        :path, Fixture_file_[ :matched_by_first_but_not_second_phase ],
        :pattern, '@todo\>',
      )

      _st = @result

      expect( _st.gets ).to be_nil

      __want_event_about_did_not_match
    end

    def __want_event_about_did_not_match

      want_neutral_event :did_not_match do | ev |

        ev = ev.to_event

        expect( black_and_white ev ).to match(
          %r(\Askipping a line that matched via `grep`) )

        expect( ev.path[ -6 .. -1 ] ).to eql '.phase'
        expect( ev.lineno ).to eql 2
        expect( ev.line[ -6 .. -1 ] ).to eql "a tag\n"
      end

      want_no_more_events
    end
  end
end
