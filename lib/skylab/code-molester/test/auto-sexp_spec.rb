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
    let(:parser_class) do
      Treetop.load_from_string grammar
    end
    let(:parser) do
      parser_class.new
    end
    it "(the treetop grammar parses inputs like normal)" do
      parser.parse('mary').should be_kind_of(Treetop::Runtime::SyntaxNode)
      parser.parse('joe bob').should be_nil
    end
    it "parse trees get a method called 'sexp'" do
      node = parser.parse('mary')
      node.should be_respond_to(:sexp)
    end
    it "does nothing interesting with a not complex grammar" do
      node = parser.parse('mary')
      sexp = node.sexp
      sexp.should eql([:terminal, "mary"])
      sexp.should be_kind_of(Skylab::CodeMolester::Sexp)
    end
  end
end

