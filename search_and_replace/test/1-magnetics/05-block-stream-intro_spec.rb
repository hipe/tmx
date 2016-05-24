require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - block stream intro" do

    # introduce exactly [#031] throughput and [#012] blocks.

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_block_stream

    context "(ensure the immutabililty of the final LTS :#decision-B)" do

      given do
        str "00\r\n1A\r\n22\r\n33\r44\n"
        rx %r(A.)
      end

      # (five LTS's, one match. the match bleeds halfway on to the second
      #  LTS. so it is the third LTS that must be used as the last LTS
      #  of the matches block.)

      it "first block is static block" do
        at_( 0 ) == :S or fail
      end

      it "second block is matches block" do
        at_( 1 ) == :M or fail
      end

      it "third block is static block" do
        at_( 2 ) == :S or fail
      end

      it "only 3 blocks" do
        block_count_ == 3 or fail
      end

      it "atoms for first static" do
        atoms_of_( _first_static ) ==
          [ :static, :content, "00", :LTS_begin, "\r\n", :LTS_end ] or fail
      end

      it "atoms for last static" do
        atoms_of_( _last_static ) ==
          [ :static, :content, "33", :LTS_begin, "\r", :LTS_end,
            :content, "44", :LTS_begin, "\n", :LTS_end ] or fail
      end

      it "atoms for matches block (orig)" do

        a = atoms_of_ block_at_ 1

        d = 0 ; len = 3
        a[d,len] == [ :static, :content, "1" ] or fail

        d += len
        len = 7
        a[d,len] == [ :match, 0, :orig, :content, "A", :LTS_begin, "\r" ] or fail

        d += len
        len = 9
        a[d,len ] == [ :static, :LTS_continuing, "\n", :LTS_end,
                       :content, "22", :LTS_begin, "\r\n", :LTS_end, ] or fail
        d += len
        a.length == d or fail
      end

      def _first_static
        block_at_ 0
      end

      def _last_static
        block_at_ 2
      end
    end

    context "(match that starts midway in an LTS, what order?)" do

      given do
        str "01\r\n45"
        rx %r(\n4)
      end

      it "first block is matches block" do
        at_( 0 ) == :M or fail
      end

      it "only one block" do
        block_count_ == 1 or fail
      end

      it "one match controller" do
        only_block_.match_controllers_count___ == 1 or fail
      end

      it "atoms for matchs block (orig)" do

        a = atoms_of_ only_block_

        d = 0 ; len = 5
        a[d,len] == [ :static, :content, "01", :LTS_begin, "\r" ] or fail

        d += len
        len = 6
        a[d,len] == [ :match, 0, :orig, :LTS_continuing, "\n", :LTS_end ] or fail

        d += len
        len = 2
        a[d,len] == [ :content, "4" ] or fail

        d += len
        len = 6
        a[d,len] == [ :static, :content, "5", :LTS_begin, EMPTY_S_, :LTS_end ] or fail

        d += len
        a.length == d or fail
      end

      def only_block_
        block_array.fetch 0
      end
    end

    context "(joint custody of an LTS)" do

      given do
        str "AB\r\nCD"
        rx %r(B\r|\nC)
      end

      it "first block is matches block" do
        at_( 0 ) == :M or fail
      end

      it "only one block" do
        1 == block_count_ or fail
      end

      it "2 MC's" do
        only_block_.match_controllers_count___ == 2 or fail
      end

      it "atoms for matches block (orig)" do

        a = atoms_of_ only_block_

        d = 0 ; len = 3
        a[d,len] == [ :static, :content, "A" ] or fail

        d += len
        len = 7
        a[d,len] == [ :match, 0, :orig, :content, "B", :LTS_begin, "\r" ] or fail

        d += len
        len = 8
        a[d,len] == [ :match, 1, :orig, :LTS_continuing, "\n", :LTS_end, :content, "C" ] or fail

        d += len
        len = 6
        a[d,len] == [ :static, :content, "D", :LTS_begin, EMPTY_S_, :LTS_end ] or fail

        d += len
        a.length == d or fail
      end
    end

    def only_block_
      block_at_ 0
    end
  end
end
