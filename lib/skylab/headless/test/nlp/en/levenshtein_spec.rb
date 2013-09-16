require_relative 'test-support'

module Skylab::Headless::TestSupport::NLP::EN::Levenshtein

  ::Skylab::Headless::TestSupport::NLP::EN[ self ]

  include CONSTANTS

  Headless = ::Skylab::Headless

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Headless::NLP::EN::Levenshtein" do
    context "we love levenshtein" do
      Sandbox_1 = Sandboxer.spawn
      it "reduce a big list to a small list" do
        Sandbox_1.with self
        module Sandbox_1
          Closest_items_to_item = Headless::NLP::EN::Levenshtein::
            With_conj_s_render_p_closest_n_items_a_item_x.
              curry[ ' or ', -> x { x.inspect }, 3 ]
          a = [ :zepphlyn, :beefer, :bizzle, :bejonculous, :wangton ]
          strange_x = :bajofer
          or_s = Closest_items_to_item[ a, strange_x ]

          msg = "'#{ strange_x }' was not found. did you mean #{ or_s }?"
          msg.should eql( "'bajofer' was not found. did you mean :beefer, :bizzle or :wangton?" )
        end
      end
    end
  end
end
