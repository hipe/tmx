require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - block stream some edges" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_block_stream

    context "gadzooks" do

      given do

        # this crazy arrangement was designed to exhibit:
        #   • multiple LTS's in one match
        #   • multiple matches in one matches block
        #   • as for end of match against end of LTS,
        #     three kinds of overlap: LT, same, GT.
        #   • a static block that in effect seaparates two matches blocks.
        #
        # one match is signified by each of A, B, C & D.
        #   • match A has an LTS that "bleeds over" its end.
        #   • match B is "same" with an LTS :#spot-5.
        #   • match C interlaps with two LTS's:
        #       + it underlaps an LTS at the match's head,
        #       + it envelops an LTS.

        # | 0 | 1m| 2m| 3m|    | |A|A|A|
        # | 4m| 5m| 6m| 7 |    |A|A|A| |
        # | 8 | 9 |10m|11m|    | | |B|B|
        # |12 |13 |14 |15m|    | | | |C|
        # |16m|17m|18m|19m|    |C|C|C|C|
        # |20m|21 |22 |23 |    |C| | | |
        # |24 |25 |26 |27 |    | | | | |
        # |28 |29 |30 |31m|    | | | |D|

        rx %r(1\r\n45\r|(?<=9)\r\n(?!\z)|\n67\r\n0|\n\z)

        str "01\r\n45\r\n89\r\n23\r\n67\r\n0o\r\n45\r\n89\r\n"
        # line     2     3     4     5     6     7     8

      end

      # (cases are all #spot-6)

      it "first block" do
        at_( 0 ) == :M or fail
      end

      it "second block" do
        at_( 1 ) == :S or fail
      end

      it "third block" do
        at_( 2 ) == :M or fail
      end

      it "three blocks total" do
        block_array.length == 3 or fail
      end

      it "static block as throughput atoms" do

        begin_want_atoms_for_ atoms_of_ block_at_ 1

        o :static, :content, "45", :LTS_begin, "\r\n", :LTS_end

        end_want_atoms_
      end

      it "last matches block (orig) as throughput atoms" do

        begin_want_atoms_for_ atoms_of_ block_at_ 2

        o :static, :content, "89", :LTS_begin, "\r"
        o :match, 0, :orig, :LTS_continuing, "\n", :LTS_end  # case 11

        end_want_atoms_
      end

      it "big kahuna (orig) as throughput atoms" do  # case 10 of #spot-6

        begin_want_atoms_for_ atoms_of_ first_block_

        o :static, :content, "0", :match, 0, :orig, :content, "1", :LTS_begin, "\r\n", :LTS_end
        o :content, "45", :LTS_begin, "\r", :static, :LTS_continuing, "\n", :LTS_end
        o :content, "89", :match, 1, :orig, :LTS_begin, "\r\n", :LTS_end
        o :static, :content, "23", :LTS_begin, "\r", :match, 2, :orig, :LTS_continuing, "\n", :LTS_end
        o :content, "67", :LTS_begin, "\r\n", :LTS_end
        o :content, "0", :static, :content, "o", :LTS_begin, "\r\n", :LTS_end

        end_want_atoms_
      end
    end

    alias_method :o, :want_atoms_
  end
end
