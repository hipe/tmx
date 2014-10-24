require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] API", wip: true do  # #quickie: no

    context "inflection hack for the action of" do

      let(:lexemes) { klass.inflection.lexemes }

      let(:subject) { "#{lexemes.verb.progressive} #{lexemes.noun.lemma}" }

      context "the render action" do
        let(:klass) { Treemap::API::Actions::Render }
        specify { should eql("rendering treemap") }
      end

      context "the base class (uselessly)" do
        let(:klass) { Treemap::API::Action }
        specify { should eql("actioning treemap") }
      end
    end
  end
end
