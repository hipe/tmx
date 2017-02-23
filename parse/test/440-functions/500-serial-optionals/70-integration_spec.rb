require_relative '../../test-support'

module Skylab::Parse::TestSupport

  module Fz_SO_I___  # :+#throwaway-module for constants generated during tests

    # <-

  TS_.describe "[pa] parse functions - serial optionals - integrate w/ int & kw" do

    TS_[ self ]

    before :all do

      G = Home_.function( :serial_optionals ).with(
        :functions,
          :non_negative_integer,
            :moniker_symbol, :integer,

          :keyword, "random" )

    end

    it "builds" do
      G or fail
    end

    it "render the syntax string with the default design" do
      G.express_all_segments_into_under( "" ).should eql "[INTEGER] [random]"
    end

    it "render the syntax string with a custom design" do

      G.express_all_segments_into_under( "",

        :any_first_constituent_string, IDENTITY_,

        :any_subsequent_constituent_string, -> s { " #{ s }" },

        :constituent_string_via_constituent_badge, -> s { "[ #{ s } ]" },

        :express_all_segments_into_under_of_constituent_reflective_function, -> y, expag, f do

          if :field == f.function_supercategory_symbol
            if :keyword == f.function_category_symbol
              y << f.moniker.as_slug
            else
              y << "<#{ f.moniker.as_slug }>"
            end
          else
            f.express_all_segments_into_under y, expag
          end
          nil
        end ).should eql '[ <integer> ] [ random ]'
    end

    it "against the empty array, does nothing" do
      _against
      @int.should be_nil
      @kw.should be_nil
      @did_parse.should eql false
      @is_complete.should eql true
    end

    it "against one strange string, does not against" do
      _against 'frinkle'
      @int.should be_nil
      @kw.should be_nil
      @did_parse.should eql false
      @is_complete.should eql false
    end

    it "good first token, strange second one" do
      _against '3', 'frinkle'
      @int.should eql 3
      @kw.should be_nil
      @did_parse.should eql true
      @is_complete.should eql false
    end

    it "two good tokens" do
      _against '3', 'random'
      @int.should eql 3
      @kw.should eql :random
      @did_parse.should eql true
      @is_complete.should eql true
    end

    it "only one token - a production of the first formal symbol" do
      _against '3'
      @int.should eql 3
      @kw.should be_nil
      @did_parse.should eql true
      @is_complete.should eql true
    end

    it "only one token - *the* production of the second formal symbol" do
      _against 'random'
      @int.should be_nil
      @kw.should eql :random
      @did_parse.should eql true
      @is_complete.should eql true
    end

    def _against * s_a
      st = input_stream_via_array s_a
      d = st.current_index
      on = G.output_node_via_input_stream st
      @int, @kw = on.value_x
      if d == st.current_index
        @did_parse = false
      else
        @did_parse = true
      end
      if st.unparsed_exists
        @is_complete = false
      else
        @is_complete = true
      end
      nil
    end
  end
  # ->
  end
end
