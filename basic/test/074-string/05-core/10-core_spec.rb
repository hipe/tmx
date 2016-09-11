require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - core - (mixed tiny)" do

    it "unindent with leading blank line" do

      # each string uses the first nonblank line to determine the indent.
      # in the first string, that indent is (at writing) 10 spaces. as such,
      # that line that says "not me" *won't* lose its leading whitespace,
      # because *its* indent is (at writing) 8 spaces, and the generated
      # regex used to unindent (matching 10 spaces) fails to match that.
      # the point is, don't use `unindent` on strings like these.

      # the second string is actually based on what the first string looks
      # like after the unindenting happens: note that the "not me" line there
      # is 8 spaces in *from* where the first content line starts.

      # if this is confusing, don't worry: it's not that important, it's
      # just proof that the function is probably working the way we think it is

      string_one = <<-HERE

          the above line was blank
            hello
        not me
      HERE

      string_two = <<-HERE

        the above line was blank
          hello
                not me
      HERE

      orig = string_one.dup

      p = _subject_proc
      p[ string_one ]
      p[ string_two ]

      string_one == orig && fail
      string_one == string_two || fail
    end

    def _subject_proc
      Home_::String.method :mutate_by_unindenting
    end
  end
end
# #this-commit - as mentioned in an above comment
