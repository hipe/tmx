module Skylab::Treemap
  describe API do
    context "inflection hack for the action of" do
      let(:stems) { klass.inflection.stems }
      let(:subject) { "#{stems.verb.progressive} #{stems.noun}" }

      context "the render action" do
        let(:klass) { API::Actions::Render }
        specify { should eql("rendering treemap") }
      end

      context "the base class (uselessly)" do
        let(:klass) { API::Action }
        specify { should eql("actioning treemap") }
      end
    end
  end
end
