require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - document - ersatz parser" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module
    end

    context '(context)' do

      shared_subject :_subject_parser do

        o = _subject_module.begin

        # --

        cache = {}  # don't make a new regex for every time a branch is pushed

        o.default_branch_end_line_matcher_by do |md|
          cache.fetch md[ :margin ] do |s|
            x = /\A#{ ::Regexp.escape md[ :margin ] }end\b/
            cache[ s ] = x
            x
          end
        end

        # --

        rx = /\A
          [ \t]+ (?:
            ' (?<single_quoted_bytes> (?: [^\\'] | \\. )* ) ' |
            " (?<double_quoted_bytes> (?: [^\\"] | \\. )* ) "
          )
        /x

        o.add_branch_line_matcher(
          %r(\A(?<margin>[\t ]*)begin\b)

        ) do |md|
          # (separate the easy problem of above from the harder problem here)

          md_ = rx.match md.post_match
          s = md_[ :single_quoted_bytes ] || md_[ :double_quoted_bytes ]
          # (we aren't gonna bother unescaping for now..)
          s
        end

        o.finish
      end

      it "builds" do
        _subject_parser
      end

      context "(input 1)" do

        shared_subject :_the_parse do

          _input_string = <<-HERE  # do not unindent. keep it indented deeply

            this line does nothing
            begin "hi"

              begin 'hello' # hello there
             zoozie
              end
            end  # hey

          HERE

          _subject_parser.parse_string _input_string
        end

        it "parses" do
          _the_parse || fail
        end

        it "structure" do

          _expect_structure [
            :blank_line,
            :nonblank_line,
            [ :nonblank_line,
              :blank_line,
              [ :nonblank_line,
                :nonblank_line,
                :ending_line
              ],
              :ending_line,
            ],
            :blank_line,
          ]
        end
      end

      # ==

      context "(input 2 - hit that thing)" do

        shared_subject :_the_parse do

          _input_string = <<-HERE  # do not unindent. keep it indented deeply
            begin "johnny"
              wizzie
            end
            begin "jammer"
            end
            begin "jizniffer"

            end
          HERE

          _subject_parser.parse_string _input_string
        end

        it "parses" do
          _the_parse || fail
        end

        it "structure" do

          _expect_structure [
            [ :nonblank_line,
              :nonblank_line,
              :ending_line,
            ],
            [ :nonblank_line,
              :ending_line,
            ],
            [ :nonblank_line,
              :blank_line,
              :ending_line,
            ],
          ]
        end

        it "as linked list it looks right" do

          as_array = _the_parse.nodes

          3 == as_array.length or fail  # sanity before we continue.
          # (only because there are no item lines at the root level)

          _A, _B, _C = as_array
          _A_oid, _B_oid, _C_oid = as_array.map( & :object_id )

          # [ _ A b ] [ a B c ] [ b C _ ]
          #   1   2     3   4     5   6

          _A.previous && fail  # 1
          _A.next.object_id == _B_oid || fail  # 2

          _B.previous.object_id == _A_oid || fail  # 3
          _B.next.object_id == _C_oid || fail  # 4

          _C.previous.object_id == _B_oid || fail  # 5
          _C.next && fail  # 6
        end

        it "identifying strings!", f: true do

          _hey = _the_parse.nodes.map( & :identifying_string )
          _hey == %w( johnny jammer jizniffer ) or fail
        end
      end
    end

    def _expect_structure exp_a
      _act = Summarize_structure_recursive__[ [], _the_parse ]
      _act == exp_a || fail
    end

    Summarize_structure_recursive__ = -> a, branch do

      # if it would be useful, you could make this an assertive operation
      # that complains early (or maybe just make one of those separately)

      branch.nodes.each do |node|
        if node.is_branch
          a.push Summarize_structure_recursive__[ [], node ]
        else
          a.push node.category_symbol
        end
      end
      a
    end

    def _subject_module
      Home_::Models_::Document::ErsatzParser
    end

  end
end
