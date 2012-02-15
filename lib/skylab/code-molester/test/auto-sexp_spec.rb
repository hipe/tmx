require File.expand_path('../test-support', __FILE__)
require File.expand_path('../../auto-sexp', __FILE__)
require 'treetop'

module Skylab::CodeMolester
  module TestNamespace::PersonName
    class Node < ::Treetop::Runtime::SyntaxNode
      extend AutoSexp
    end
  end
end

describe ::Skylab::CodeMolester::AutoSexp do
  let(:parser_class) do
    Treetop.load_from_string grammar
  end
  let(:parser) do
    parser_class.new
  end
  let(:subject) { parser.parse(input).sexp }
  context "With a grammar for first names" do
    let(:grammar) do
      <<-HERE.deindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName
            rule person_name
              [a-z]+ <Node>
            end
          end
        end
      HERE
    end
    it "(the treetop grammar parses inputs like normal)" do
      parser.parse('mary').should be_kind_of(Treetop::Runtime::SyntaxNode)
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
      <<-HERE.deindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName
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
      parser.parse('mary').should be_kind_of(Skylab::CodeMolester::TestNamespace::PersonName::Node)
      parser.parse('joe bob').should be_kind_of(Skylab::CodeMolester::TestNamespace::PersonName::Node)
      parser.parse('joe bob briggs').should be_nil
    end
    context "because the grammar is more complex, stuff starts to happen magically" do
      context 'the sexp for the string "mary"' do
        let(:input) { "mary" }
        let(:expected) { [:person_name, [:first, "mary"], [:last, '']] }
        specify { should eql(expected) }
        specify { should be_kind_of(::Skylab::CodeMolester::Sexp) } # !
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
      <<-HERE.deindent
        module Skylab::CodeMolester::TestNamespace
          grammar PersonName
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
end

