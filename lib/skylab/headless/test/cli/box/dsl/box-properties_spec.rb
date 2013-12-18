require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] CLI box DSL box properties" do

    extend TS__

    context "you can still reach some of the properties of the box itself" do

      box_DSL_class :Wooza_BP do

        box.desc 'totes'

        box.desc do |y|
          y << "i was #{ say { em 'a little' } } worried"
        end

        desc "inglefish"

        def wooperly
        end

        desc do |y|
          y << "humperdick #{ say { em 'crosselapatch' } }"
        end

        def wasserly
        end
      end

      it "like desc" do
        invoke '-h'
        expect :styled, /\Ausage: yerp wooza-bp /
        expect_blank
        expect_header :description
        expect %r(\A {2,}totes\z)
        expect :styled, %r(\A {2,}i was a little worried\z)
        expect_blank
        expect_header :options
        expect %r(\A {2,}-h, )
        expect_blank
        expect_header :actions
        expect :styled, %r(\A {2,}wooperly {2,}inglefish\z)
        expect :styled, %r(\A {2,}wasserly {2,}humperdick crosselapatch\z)
        expect_blank
        expect %r(\bfor help on that action\z)
        expect_succeeded
      end
    end
  end
end
