require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] ersatz parser - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :ersatz_parser

    it "loads" do
      ersatz_lib_module_
    end

    context '(context)' do

      it "builds" do
        grammar_one_parser_
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

          grammar_one_parser_.parse_string _input_string
        end

        it "parses" do
          _the_parse || fail
        end

        it "structure" do

          _want_structure [
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

          grammar_one_parser_.parse_string _input_string
        end

        it "parses" do
          _the_parse || fail
        end

        it "structure" do

          _want_structure [
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

        it "identifying strings!" do

          _hey = _the_parse.nodes.map( & :document_unique_identifying_string )
          _hey == %w( johnny jammer jizniffer ) or fail
        end
      end
    end

    def _want_structure exp_a
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
  end
end
# #tombstone: used to have linked list
