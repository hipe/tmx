module Skylab::DocTest::TestSupport
  class Case
    # -
      module Test_Context_Instance_Methods  # part of public API too

        def expect_case name_i
          @kase = fake_file_structure_for_path( big_file_path_ ).case name_i
          @node_upstream = via_case_build_node_stream
          _expect_tree = @kase.predicate_tree
          run_case_expectations_of_tree_children _expect_tree
        end

        def via_case_build_node_stream
          cb_stream = cb_stream_via_fake_file @kase.example_ff
          cb = cb_stream.gets
          cb_stream.gets and fail
          o = magnetics_module_
          _ss = o::SpanStream_via_CommentBlock[ cb ]
          o::NodeStream_via_SpanStream[ _ss ]
        end

        def run_case_expectations_of_tree_children tree
          expect_stream = tree.to_child_stream
          node = expect_stream.gets
          ok = true
          while node
            x = node.value_x
            ok = send x.test_context_method_name, x
            ok or break
            if node.child_count.nonzero?
              ok = run_case_expectations_of_tree_children node
              ok or break
            end
            node = expect_stream.gets
          end
          if ok
            ok = check_for_extra_case_nodes
          end
          ok
        end

        def expect_test_case_context_node eg
          ok = common_expect_test_case_node eg
          ok and via_node_expect_test_case_context eg
        end

        def expect_test_case_example_node eg
          ok = common_expect_test_case_node eg
          ok and via_node_expect_test_case_example eg
        end

        def expect_before_block eg
          ok = common_expect_test_case_node eg
          ok and via_node_expect_test_case_before eg
        end

        def expect_test_case_let_expression eg
          common_expect_test_case_node eg
        end

        def via_node_expect_test_case_context eg
          # we might one day validate description strings like the other

          x = @node_upstream.gets
          x and raise "re-implement this so that both the expectation and #{
            }the actuals side are args not ivars, OR use actors etc"

          @node_upstream = @node.to_child_stream
          ACHIEVED_
        end

        def via_node_expect_test_case_example eg
          exp_s = eg.expected_description_string
          if exp_s
            act_s = @node.description_string
            if exp_s == act_s
              ACHIEVED_
            else
              act_s.should eql exp_s
              UNABLE_
            end
          else
            ACHIEVED_
          end
        end

        def via_node_expect_test_case_before eg
          exp_i = eg.before_block_category_symbol
          act_i = @node.before_block_category_symbol
          if exp_i == act_i
            ACHIEVED_
          else
            act_i.should eql exp_i
            UNABLE_
          end
        end

        def common_expect_test_case_node eg
          @node = @node_upstream.gets
          if @node
            if eg.expected_node_symbol == @node.node_symbol
              ACHIEVED_
            else
              @node.node_symbol.should eql eg.expected_node_symbol
              UNABLE_
            end
          else
            when_expected_case_node_not_found eg
          end
        end

        def when_expected_case_node_not_found eg
          fail "expected '#{ eg.expected_node_symbol }', had no more nodes"
          UNABLE_
        end

        def check_for_extra_case_nodes
          node = @node_upstream.gets
          if node
            fail "expected no more nodes, had '#{ node.node_symbol }'"
            UNABLE_
          else
            ACHIEVED_
          end
        end
      end

      def initialize *a
        eg_name, @example_ff, pred_cat, @predicate_ff = a
        @predicate_category_symbol = pred_cat.intern
        eg_name.gsub! NON_ALPHA_RX__, EMPTY_S_
        @case_name_symbol = Common_::Name.via_human( eg_name ).
          as_lowercase_with_underscores_symbol
      end

      NON_ALPHA_RX__ = /[^a-z0-9 ]+/i

      attr_reader :case_name_symbol, :example_ff

      def predicate_tree

        Home_.lib_.basic::Tree.via(
          :indented_line_stream, @predicate_ff.fake_open,
          :glyph, '+ ',
          :build_using, method( :bld_node ) )

      end

      def bld_node line_content_string, parent, & oes_p
        Build_predicate__.call line_content_string, parent, & oes_p
      end

      module Build_predicate__

        class << self

          def call line_s, parent, & oes_p

            line_s.chomp!

            cls = md = nil
            Predicates__.constants.each do |i|
              cls = Predicates__.const_get i
              md = cls.match line_s
              md and break
            end

            if md
              cls.build md, parent, & oes_p
            else
              raise "did not match anything: #{ line_s.inspect }"
            end
          end
        end
      end

      class Predicate_

        class << self

          def match s
            self::RX.match s
          end

          def build md, parent, & oes_p
            new( md, parent, & oes_p ).normalize
          end
        end

        def initialize md, parent, & oes_p
          @md = md ; @parent = parent ; @on_event_selectively = oes_p
        end

        def normalize
          self
        end

        def parse_pred
          ok = true
          d = 0
          @pool_a = self.class::POOL_A.dup
          length = @pred_s.length
          begin

            md = SPACE_RX__.match @pred_s, d
            if md
              d += md[ 0 ].length
            end

            found = found_index = md = nil
            @pool_a.each_with_index do |x, idx|
              md = x.rx.match @pred_s, d
              if md
                found = x
                found_index = idx
                break
              end
            end

            if found
              d += md[ 0 ].length
              ok = send found.method_name, md
              ok or break
              d == length and break
              if 1 == @pool_a.length
                fail "empty pool when #{ @pred_s[ d .. -1 ].inspect }"
              else
                @pool_a[ found_index ] = nil
                @pool_a.compact!
              end
            else
              fail "unable to parse #{ @pred_s[ d .. -1 ].inspect }"
            end
          end while nil
          ok
        end
        SPACE_RX__ = /\G[[:space:]]+/

      end

      Pred_ = ::Struct.new :method_name, :rx

      module Predicates__

        class Example__ < Predicate_

          RX = /\A(?:an )?example node(.+)?\z/i

          def normalize
            @pred_s = @md[ 1 ]
            if @pred_s
              parse_pred and self
            else
              super
            end
          end

          POOL_A = [
            Pred_[ :add_description_assertion, /\G(?:with|and)(?: the)? description "((?:\\"|(?!").)*)"/ ]
          ]

          def add_description_assertion md
            s = md[ 1 ]
            s.gsub! %r(\\(["\\])) do
              $~[ 1 ]
            end
            @expected_description_string = s
            ACHIEVED_
          end

          def test_context_method_name
            :expect_test_case_example_node
          end

          attr_reader :expected_description_string

          def expected_node_symbol
            :example_node
          end
        end

        class Context__ < Predicate_

          RX = /\A(?:a )context node with:?\z/i

          def test_context_method_name
            :expect_test_case_context_node
          end

          def expected_node_symbol
            :context_node
          end
        end

        class Before__ < Predicate_

          RX = /\A(?:a )before (all|each) block\z/i

          def normalize
            @before_block_category_symbol = @md[ 1 ].intern
            self
          end

          attr_reader :before_block_category_symbol

          def test_context_method_name
            :expect_before_block
          end

          def expected_node_symbol
            :before_node
          end
        end

        class A_Let_Expression__ < Predicate_

          RX = /\A(?:a )let expression\z/i

          def test_context_method_name
            :expect_test_case_let_expression
          end

          def expected_node_symbol
            :let_assignment
          end
        end
      end

      # <-

    ACHIEVED_ = true
  end
end
