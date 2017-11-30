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
      expect( G.express_all_segments_into_under "" ).to eql "[INTEGER] [random]"
    end

    it "render the syntax string with a custom design" do

      _x = G.express_all_segments_into_under( "",

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
        end,
      )

      expect( _x ).to eql '[ <integer> ] [ random ]'
    end

    it "against the empty array, does nothing" do
      _against
      _int_nil
      _keyword_nil
      _did_not_parse
      _is_complete
    end

    it "against one strange string, does not against" do
      _against 'frinkle'
      _int_nil
      _keyword_nil
      _did_not_parse
      _is_not_complete
    end

    it "good first token, strange second one" do
      _against '3', 'frinkle'
      _int 3
      _keyword_nil
      _did_parse
      _is_not_complete
    end

    it "two good tokens" do
      _against '3', 'random'
      _int 3
      _keyword_random
      _did_parse
      _is_complete
    end

    it "only one token - a production of the first formal symbol" do
      _against '3'
      _int 3
      _keyword_nil
      _did_parse
      _is_complete
    end

    it "only one token - *the* production of the second formal symbol" do
      _against 'random'
      _int_nil
      _keyword_random
      _did_parse
      _is_complete
    end

    def _did_not_parse
      expect( @did_parse ).to eql false
    end

    def _did_parse
      expect( @did_parse ).to eql true
    end

    def _is_not_complete
      expect( @is_complete ).to eql false
    end

    def _is_complete
      expect( @is_complete ).to eql true
    end

    def _int_nil
      expect( @int ).to be_nil
    end

    def _int d
      expect( @int ).to eql d
    end

    def _keyword_random
      expect( @kw ).to eql :random
    end

    def _keyword_nil
      expect( @kw ).to be_nil
    end

    def _against * s_a
      st = input_stream_via_array s_a
      d = st.current_index
      on = G.output_node_via_input_stream st
      @int, @kw = on.value
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
# #history-A.1: when eradicating `should`, left old asserts as-is plus refactor
#  (as opposed to doing what we do these days) for the big test
