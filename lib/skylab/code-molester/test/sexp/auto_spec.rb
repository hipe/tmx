require_relative 'auto/test-support'

module ::Skylab::CodeMolester::TestSupport

  include ::Skylab::CodeMolester::TestSupport::CONSTANTS
  # wow scope rules changed btwn 1.9.2 and 1.9.3..
  CodeMolester = CodeMolester  # yes
# ..

describe ::Skylab::CodeMolester::Sexp::Auto do

  cache = { }                     # avoid warnings about etc. don't worry,
                                  # cacheing like this is *always* fine

  let :parser_class do
    wat = cache.fetch( grammar ) do |str|
      g = CodeMolester::Services::Treetop.load_from_string str
      cache[ str ] = g
      g
    end
    wat
  end


  let(:parser) { parser_class.new }
  let(:parse_result) { parser.parse(input) }
  let(:sexp) { parse_result.sexp }
  let(:subject) { parse_result.sexp }
  context "With a grammar for first names" do
    let(:grammar) do
      <<-HERE.unindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName_01
            rule person_name
              [a-z]+ <Node>
            end
          end
        end
      HERE
    end
    it "(the treetop grammar parses inputs like normal)" do
      parser.parse('mary').should be_kind_of(
        CodeMolester::Services::Treetop::Runtime::SyntaxNode )
      parser.parse('joe bob').should be_nil
    end
    it "parse trees get a method called 'sexp'" do
      node = parser.parse('mary')
      node.should be_respond_to(:sexp)
    end
    context "it does nothing interesting with a not complex grammar" do
      context 'the sexp for the string \"mary\"' do
        let(:input) { "mary" }
        let(:expected) { "mary" }
        specify { should eql(expected) }
      end
    end
  end
  context "With a grammar for first and last names" do
    let(:grammar) do
      <<-HERE.unindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName_02
            rule person_name
              t_1_first:( [a-z]+ )
              n_2_last:(
                w_1:' '+
                t_3_body:( [a-z]+ )
              )?
              <Node>
            end
          end
        end
      HERE
    end
    it "(the treetop grammar parses inputs like normal)" do
      parser.parse('mary').should be_kind_of(CodeMolester::TestNamespace::PersonName_02::Node)
      parser.parse('joe bob').should be_kind_of(CodeMolester::TestNamespace::PersonName_02::Node)
      parser.parse('joe bob briggs').should be_nil
    end
    context "because the grammar is more complex, stuff starts to happen magically" do
      context 'the sexp for the string "mary"' do
        let(:input) { "mary" }
        let(:expected) { [:person_name, [:first, "mary"], [:last, '']] }
        specify { should eql(expected) }
        specify { should be_kind_of(CodeMolester::Sexp) } # !
      end
      context 'the sexp for the string "joe bob" (note it is sub-optimal)' do
        let(:input) { "joe bob" }
        let(:expected) { [:person_name, [:first, "joe"], [:last, " bob"] ] }
        specify { should eql(expected) }
      end
    end
  end
  context "With a grammar for first and last names broken up differently" do
    let(:grammar) do
      <<-HERE.unindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName_03
            rule person_name
              t_1_first:name
              n_2_last:(
                ' '+
                name
              )?
              <Node>
            end
            rule name
              [a-z]+
              <Node>
            end
          end
        end
      HERE
    end
    it "(the treetop grammar parses inputs like normal)" do
      parser.parse('mary').should_not be_nil
      parser.parse('joe bob').should_not be_nil
      parser.parse('joe bob briggs').should be_nil
    end
    context "because the grammar is broken up more optimally" do
      context 'the sexp for the string "mary"' do
        let(:input) { "mary" }
        let(:expected) { [:person_name, [:first, "mary"], [:last, '']] }
        specify { should eql(expected) }
      end
      context 'the sexp for the string "joe bob" now has a thing that is accessible' do
        let(:input) { "joe bob" }
        let(:expected) { [:person_name, [:first, "joe"], [:last, " ", "bob"] ] }
        specify { should eql(expected) }
      end
    end
  end

  context "When you want custom sexp classes" do

    module ::Skylab::CodeMolester::TestNamespace

      class MySexp < CodeMolester::Sexp
      end

      class Bread < MySexp

        MySexp[:top_slice] = self
        MySexp[:bottom_slice] = self

        def calories
          "#{ unparse } has 100 calories"
        end
      end

      module Sandwich

        class MyNode < CodeMolester::Services::Treetop::Runtime::SyntaxNode

          extend CodeMolester::Sexp::Auto
          sexp_auto_class MySexp

          # CodeMolester::Sexp::Auto.enhance( self ).sexp_auto_class MySexp

        end
      end
    end

    let(:grammar) do
      <<-HERE.unindent
        module Skylab::CodeMolester::TestNamespace
          grammar Sandwich
            rule sandwich
              t_1_top_slice:bread
              ' '
              n_2_items:items
              ' '
              t_3_bottom_slice:bread
              <MyNode>
            end
            rule bread
              'rye' / 'white' / '7 grain'
            end
            rule items
              t_1_item:item
              n_2_more_items:( ' ' n_1_item:item )*
              <MyNode>
            end
            rule item
              'lettuce' / 'tomato'
              <MyNode>
            end
          end
        end
      HERE
    end

    context "(this tree is ANNOYING)" do
      let :input do
        'rye lettuce tomato rye'
      end

      let :expected do
        [ :sandwich,
          [:top_slice, "rye"],
          [:items, [:item, "lettuce"], [:more_items, " tomato"]],
          [:bottom_slice, "rye"] ]
      end

      it 'works' do
        raw_tree = parse_result
        s = raw_tree.sexp
        s.should eql( expected )
      end
    end

    context "you register them as above and everything just works magically" do
      let(:input) { '7 grain lettuce tomato 7 grain' }
      context "a sexp node with whose label you registered a custom class, e.g. Bread" do
        let(:subject) { sexp.detect(:top_slice).class }
        specify { should eql(CodeMolester::TestNamespace::Bread) }
      end
      context 'calling the custom method ("calories") on your custom sexp class' do
        let(:subject) { sexp.detect(:top_slice).calories }
        specify { should eql("7 grain has 100 calories") }
      end
    end
  end
end
# ..
end
