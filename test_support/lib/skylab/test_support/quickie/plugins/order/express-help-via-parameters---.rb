module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class ExpressHelp_via_Parameters___

        class << self
          def [] a, b, c
            new( a, b, c ).execute
          end
          private :new
        end  # >>

        def initialize y, default, flag
          @default = default
          @flag = flag
          @_y = y
        end

        def execute
          __init_big_string
          __init_paragraph_stream_via_big_stream
          __express_paragraph_stream
        end

        def __init_paragraph_stream_via_big_stream

          # rather than on the one extreme writing one big chunk to stdout
          # (bad style), or on the other extreme breaking this up into
          # individual lines and outputting those, just for fun we go with
          # a middle ground:
          # chunk the big string into the real paragraphs (those chunks
          # separated by two or more newlines) and output those paragraphs
          # one at at time.

          scn = Home_::Library_::StringScanner.new @_big_string

          body_rx = /(?:[^\n]|\n(?!\n)+)+\n?/
          skip_rx = /\n/

          p = -> do
            s = scn.scan( body_rx ) or fail
            d = scn.skip( skip_rx )
            if ! d
              p = EMPTY_P_
            end
            s
          end

          @_paragraph_stream = Common_.stream do
            p[]
          end
          NIL_
        end

        def __express_paragraph_stream

          y = @_y
          st = @_paragraph_stream

          para_s = st.gets
          if para_s
            y << para_s
            begin
              para_s = st.gets
              para_s or break
              y << nil
              y << para_s
              redo
            end while nil
          end
          y
        end

        def __init_big_string

          flag = @flag

          @_big_string = <<-HERE.unindent
          this plugin is inspired by -depth (see), and perhaps supersedes it.

          this plugin effects what we call "regression-friendly" order:

          we can name and structure our test files in such a way that the
          name and placement of the files expresses how those tests relate
          to one another (in terms of complexity, dependency, etc).

          then when running the test suite we can leverage this convention
          to optimize the test run for various concerns, for example:

            • to run the tests in a "fail fast" order (higher-level first)

            • to run them in a "regression-friendly" (debugging) mode
              (unit first)

            • to run them with a focus on a certain sub-sub-system

          the primary behavior that this plugin implements is to sort a
          flat list of spec files into a "regression friendly" order,
          effecting (and in effect determining) our "rules" for this order:

          1) in regards to sorting, a file is equivalent to a directory that
             contains only that file. (i.e a branch node with one leaf child
             is equivalent to just that leaf child.)

             this is a somewhat arbitrary design decision that has emerged
             from real world use. it lets us avoid creating "orphan" files
             just to effect a particular ordering. (i.e in this regard
             numbering trumps depth.)

          2) after applying the above conceptual distinction, branch nodes
             effectively divide their children into two categories:

             A) those whose entry name *does* start with an integer.

             B) and all the others (i.e those whose name does *not*),

             groups (A) and (B) have their own sorting criteria to be
             defined next. but the uptake here is that *at this branch node*,
             all (A) are "placed" *before* all (B).

          3) the nodes in group (A) are effectively sorted in ascending
             order by integer with these details:

            • a zero-padded integer is identical to the same integer without
              padding, so padding can be used aesthetically in filenames
              with no impact on the sort.

            • the integer parsing stops at any first character that is not
              an integer, so [ "1A", "1.5A" ] will not sort as you might
              like (for now) (because "A" comes before "." lexically).

            • we do not define behavior for what happens when two different
              entries have the same effective integer. (we could, but we
              don't want to support trees like this.)

          4) those in group (B) are sorted by whatever rationale the platform
             uses by default for sorting strings. but NOTE it is not
             recommended that this behavior be seen as reliable! it is
             implemented mostly to normalize any unreliability from the
             underlying systems. when chosing a file name, the lexical ranking
             of the file name relative to sibling entries should *not* be
             a design consideration.

          this sort criteria is effected recursively on each directory.

          NOW, if you understand all that we are ready to begin explaining
          what the arguments do: `#{ flag }=M-N` says "run the spec files
          'M' thru 'N' inclusive" where 'M' and 'N' are *ordinal* numbers
          referencing the files in the sorted list, starting from 1.

          so, `#{ flag }=1-3` will run the first, second and third spec
          file in the ordered list.

          all invalid input will have its failure explained:

            • because these are ordinals and not offsets, 0 is invalid.
            • negative numbers are not (yet) supported.

          you can use the literal string 'N' (without the quotes) to signify
          the last file in the ordered list. so if there are six spec files;
          `#{ flag }=4-N` will select the fourth, fifth and sixth files.

          `#{ flag }=1-N` will always do all the files in order, however
          many files there are. you can use little 'n' instead of big 'N'.

          flipping the order of the two numbers so that the 'N'
          term comes before the 'M' term will reverse the order of the files.
          `#{ flag }=3-1` will do the third, second, then first file.
          `#{ flag }=N-4` wil do the sixth, fifth, then fourth file.
          (this can be useful when you are trying to fail as early as
          possible by running integration-like tests first for whatever
          reason, assuming you structured your tree in the conventional way.)

          FINALLY, if you provide no argument to the `#{ flag }` switch,
          the default is "#{ DEFAULT__ }".
          HERE
          NIL_
        end
      end
    end
  end
end
