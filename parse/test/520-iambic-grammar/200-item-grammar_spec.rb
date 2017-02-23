require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] iambic grammar - item grammar" do

    it "builds" do
      _subject
    end

    it "just one keyword" do

      st = _around :tea

      _x = st.gets
      st.gets.should be_nil

      _x.to_a.should eql [ nil, :tea, nil ]
    end

    it "plain kw then kw with 1 adj" do

      st = _around :tea, :hot, :tea

      _x = st.gets
      sp = st.gets
      st.gets.should be_nil

      _x.to_a.should eql [ nil, :tea, nil ]
      adj = sp.adj
      adj[ :hot ].should eql true
      adj[ :cold ].should be_nil

      sp.keyword_value_x.should eql :tea

    end

    it "1 pp" do

      st = _around :tea, :with, :wazoozle

      sp = st.gets
      st.gets.should be_nil

      pp = sp.pp
      pp.with.should eql :wazoozle
      pp.and.should be_nil
    end

    def _around * x_a
      _subject.simple_stream_of_items_via_polymorpic_array x_a
    end

    define_method :_subject, -> do

      subject = nil

      -> do
        subject ||= __build_subject
      end
    end.call

    def __build_subject

      TS_.const_set(
        :IG_Shh___,
        Home_::IambicGrammar::ItemGrammar_LEGACY.new( [ :hot, :cold ], :tea, [ :with, :and ] ) )
    end
  end
end
