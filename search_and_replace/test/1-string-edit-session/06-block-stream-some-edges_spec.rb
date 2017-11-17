require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - block stream some edges" do

    # (this is the coverage counterpart to #spot-6)

    TS_[ self ]
    use :memoizer_methods
    use :SES_block_stream

    # (case 1 is covered in the previous spec)

    context "case 2, case 3 - L-jutting & L-enveloping" do

      given do

        str "\r\nwoah\r\n"

        rx %r(
          \n(?=w) |       # match a \n character that is followed by a 'w' OR
          (?<=h\r)(?=\n)  # match the boundary between '\r' and '\n'
        )x
      end

      it "first block is matches block" do
        at_( 0 ) == :M or fail
      end

      it "only 1 block" do
        block_count_ == 1 or fail
      end

      it "atoms for matches block" do

        begin_want_atoms_for_ atoms_of_ first_block_

        o :static, :LTS_begin, "\r"
        o :match, 0, :orig, :LTS_continuing, "\n", :LTS_end
        o :static, :content, "woah", :LTS_begin, "\r"
        o :match, 1, :orig
        o :static, :LTS_continuing, "\n", :LTS_end

        end_want_atoms_
      end
    end

    context "case 4, case 8 - M-lagging, M-jutting" do

      given do
        str "A\nB\nC\n"
        rx %r(\nB|C\n)
      end

      it "first block is matches block" do
        at_( 0 ) == :M or fail
      end

      it "only 1 block" do
        block_count_ == 1 or fail
      end

      it "2 MC's" do
        first_block_.match_controllers_count___ == 2 or fail
      end

      it "atoms for matches block" do

        begin_want_atoms_for_ atoms_of_ first_block_

        o :static, :content, "A"
        o :match, 0, :orig, :LTS_begin, "\n", :LTS_end, :content, "B"
        o :static, :LTS_begin, "\n", :LTS_end
        o :match, 1, :orig, :content, "C", :LTS_begin, "\n", :LTS_end

        end_want_atoms_
      end
    end

    context "case 5, case 6 - \"same\", L-lagging" do

      given do

        str "\n\r\n"

        rx %r(\A\n|\r)
      end

      it "first block is matches block" do
        at_( 0 ) == :M or fail
      end

      it "only 1 block" do
        block_count_ == 1 or fail
      end

      it "atoms for matches block" do

        begin_want_atoms_for_ atoms_of_ first_block_

        o :match, 0, :orig, :LTS_begin, "\n", :LTS_end
        o :match, 1, :orig, :LTS_begin, "\r"
        o :static, :LTS_continuing, "\n", :LTS_end

        end_want_atoms_
      end
    end

    context "case 7 - multiline match" do

      given do
        str "biff\nfoo\nbar\nbaz\n"
        rx %r(oo\nbar\nba)
      end

      it "first block is static block" do
        at_( 0 ) == :S or fail
      end

      it "second block is matches block" do
        at_( 1 ) == :M or fail
      end

      it "only 3 blocks" do
        block_count_ == 2 or fail
      end

      it "atoms for matches block" do

        begin_want_atoms_for_ atoms_of_ block_at_ 1

        o :static, :content, "f"
        o :match, 0, :orig, :content, "oo", :LTS_begin, "\n", :LTS_end,
          :content, "bar", :LTS_begin, "\n", :LTS_end,
          :content, "ba"
        o :static, :content, "z", :LTS_begin, "\n", :LTS_end

        end_want_atoms_
      end
    end

    # case 9 is covered in the previous file

    context "case 10 - noverlap" do

      given do
        str "bunny bunnny\n"
        rx %r(\bbun+y\b)
      end

      it "atoms for matches block" do

        begin_want_atoms_for_ atoms_of_ first_block_

        o :match, 0, :orig, :content, "bunny"
        o :static, :content, " "
        o :match, 1, :orig, :content, "bunnny"
        o :static, :LTS_begin, NEWLINE_, :LTS_end
      end
    end

    alias_method :o, :want_atoms_
  end
end
