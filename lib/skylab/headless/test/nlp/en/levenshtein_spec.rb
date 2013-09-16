require_relative 'test-support'

module Skylab::Headless::TestSupport::NLP::EN::Levenshtein_

  ::Skylab::Headless::TestSupport::NLP::EN[ self ]

  include CONSTANTS

  Headless = ::Skylab::Headless

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Headless::NLP::EN::Levenshtein_" do
    context "we love levenshtein" do
      Sandbox_1 = Sandboxer.spawn
      it "reduce a big list to a small list" do
        Sandbox_1.with self
        module Sandbox_1
          Or_ = Headless::NLP::EN::Levenshtein_::Templates_::Or_
          a = [ :zepphlyn, :beefer, :bizzle, :bejonculous, :wangton ]
          strange_x = :bajofer
          or_s = Or_[ a, strange_x, 3, -> x { x.inspect } ]

          msg = "'#{ strange_x }' was not found. did you mean #{ or_s }?"
          msg.should eql( "'bajofer' was not found. did you mean :beefer, :bizzle or :wangton?" )
        end
      end
    end
  end
end
