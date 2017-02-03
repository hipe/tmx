require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - styling" do

    it "loads" do
      _subject_module || fail
    end

    it "styles" do

      _act = _subject_module::Stylize[ 'blue', :strong, :red ]
      _act == "\e[1;31mblue\e[0m" || fail
    end

  context "chunker" do

    it "loads" do
      _subject_performer
    end

    it "empty string - empty stream" do

      against_string_ EMPTY_S_
      st = flush_to_subject_result_
      _x = st.gets
      _x.nil? || fail
      _x = st.gets
      _x.nil? || fail
    end

    it "no-styled string - stream with one item as-is" do
      against_string_ "foo"
      expect_ "foo"
    end

    it "even if the string has what LOOKS like an excape sequence but isn't" do
      same = "foo\e[32;mbar"
      against_string_ same
      expect_ same
    end

    it "first money variation A" do
      against_string_ "\e[32;1mfoo"
      expect_ EMPTY_S_ do |y|
        y << [ [:green, :strong], "foo" ]
      end
    end

    it "first money variation B" do
      against_string_ "hi\e[32;1mfoo"
      expect_ "hi" do |y|
        y << [ [:green, :strong], "foo" ]
      end
    end

    it "typical" do
      against_string_ "how \e[32;1mARE\e[0m you?"
      expect_ "how " do |y|
        y << [ [:green, :strong], "ARE" ]
        y << [ [:no_style], " you?" ]
      end
    end

    it "end on styled" do

      against_string_ "hello \e[32;1mTHERE\e[0m"

      expect_ "hello " do |y|
        y << [ [:green, :strong], "THERE" ]
        y << [ [:no_style], EMPTY_S_ ]
      end
    end

    def against_string_ s
      @STRING = s
    end

    def expect_ head_s

      st = flush_to_subject_result_
      s = st.gets
      s == head_s || fail

      if block_given?
        sexps = []
        _y = ::Enumerator::Yielder.new do |sexp|
          sexps.push sexp
        end
        yield _y
        __CLI_styling_expect_the_rest st, sexps
      end
      NIL
    end

    def __CLI_styling_expect_the_rest actual_st, sexps

      # (reminder: on the expected side, it's a plain array; on the
      #  actual side, it's our bespoke structure from the asset node.)

      expected_st = Stream_[ sexps ]
      begin
        chunk = actual_st.gets
        chunk || break
        expected = expected_st.gets
        expected || break
        chunk.styles == expected.fetch(0) || fail
        chunk.string == expected.fetch(1) || fail
        redo
      end while above

      if chunk
        fail "had unexpected extra chunk in stream: #{ chunk.inspect }"
      end

      expected = expected_st.gets
      if expected
        fail "expecting #{ expected.inspect } at end of stream"
      end
      NIL
    end

    def flush_to_subject_result_
      _s = remove_instance_variable :@STRING
      _st = _subject_performer[ _s ]
      _st  # #todo
    end

    def _subject_performer
      _subject_module::ChunkStream_via_String
    end
  end

    def _subject_module
      Home_::CLI::Styling
    end
  end
end
