require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - reduce (integrate with markdown)", wip: true do

    TS_[ self ]
    use :want_event

# (1/N)
    it "if persistend table count is high" do

      call_API :survey, :reduce,
        :path, dir( :high_table_number )

      want_not_OK_event :early_end_of_stream
      want_fail
    end

# (2/N)
    it "integrate with markdown - will recognize the peristed table count" do

      call_API :survey, :reduce,
        :path, dir( :two_tables )

      want_no_events

      st = @result
      e = st.gets
      e_ = st.gets
      e__ = st.gets
      st.gets.should be_nil

      e[ :name ].should eql 'create'
      e_[ :name ].should eql 'edit'
      e__[ :name ].should eql 'reduce'

    end

# (3/N)
    it "integrate with markdown - override with your own table count" do
      call_API :survey, :reduce,
        :path, dir( :two_tables ),
        :table_number, '1'
      want_no_events
      st = @result
      st.gets.get_property_name_symbols.should eql [ :"prog lang name" ]
      st.gets.get_property_name_symbols.should eql [ :"prog lang name", :"misc tags" ]
      st.gets.should be_nil
    end

# (4/N)
    it "a reduce with no functions looks like an upstream map" do

      call_API :survey, :reduce,
        :upstream, file( :minimal_json )

      want_no_events
      st = @result

      e = st.gets
      e[ :desc ].should eql "my favorite socks"

      e = st.gets
      e[ :"flat tags" ].should eql [ "foo", "bar", "biff-baz:boffo" ]

      e[ :whatever ].should eql meh: "bleh"

      st.gets.should be_nil
    end

# (5/N)
    it "table number against an adapter that doesn't have tables" do

      call_API :survey, :reduce,
        :table_number, 3,
        :upstream, file( :minimal_json )

      _em = want_event :early_end_of_stream

      want_no_more_events

      black_and_white( _em.cached_event_value ).should match(

        %r(\bJSON files are always exactly one entity #{
         }collection.+table 3 was requested, but had only 1 table\b) )

      want_fail
    end
  end
end
