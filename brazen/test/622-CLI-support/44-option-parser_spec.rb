require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - option parser - actors" do

    TS_[ self ]
    use :memoizer_methods

    context "a hack to see if a basic switch looks to be present in an array" do

      shared_subject :p do
        Home_::CLI_Support::Option_Parser::Magnetics::Build_basic_switch_proc[ '--foom' ]
      end

      it "if the argv doesn't include it, result is nil" do
        expect( p[ [ 'abc' ] ] ).to eql nil
      end

      it "if the argv includes a token that matches it partially, result is index" do
        expect( p[ [ 'abc', '--fo', 'def' ] ] ).to eql 1
      end

      it "but it won't do this fuzzy matching in the other direction" do
        expect( p[ [ '--foomer', '-fap', '-f', '--foom' ] ] ).to eql 2
      end
    end
  end
end
