require_relative 'test-support'

module Skylab::Treemap::TestSupport

  describe "#{ Treemap::API }" do

    context "inflection hack for the action of" do

      let(:stems) { klass.inflection.stems }

      let(:subject) { "#{stems.verb.progressive} #{stems.noun}" }

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
