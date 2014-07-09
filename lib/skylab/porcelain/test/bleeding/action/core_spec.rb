require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action # #po-008

  describe "[po][bl] action" do

    extend Action_TestSupport

    incrementing_anchor_module!

    with_namespace 'herp-derp'

    context "You can't have an action that is a completely blank slate #{
        }class because that" do

      with_action 'ferp-merp'
      klass :HerpDerp__FerpMerp
      remove_method :subject # avoids a warning # ./test/all req -v porcelain
      let(:subject) { -> { fetch } }
      specify { should raise_error( ::NameError,
                           /undefined method `process' for class.+FerpMerp/) }
    end

    context "So if you make an action class called FerpMerp that does #{
        }nothing but define process(), it" do

      with_action 'ferp-merp'
      klass :HerpDerp__FerpMerp do
        def process ; end
      end
      specify do
        should be_action( aliases: ['ferp-merp'] )
      end
    end

    context "If you make an action class that #{
        }does nothin gbut extend #{ Bleeding::Action }, it" do

      with_action 'ferp-merp'
      klass :HerpDerp__FerpMerp do
        extend Bleeding::Action
      end
      specify do
        should be_action( aliases: ['ferp-merp'] )
      end
    end

    context "Once you decide to extend (or subclass a class that #{
        } extends) this, the magic really starts to happen!!!!!!" do

      context "For example, you can use the desc() method to #{
          }describe your interface element" do

        context "with just one line" do

          with_action 'ferp-merp'

          klass :HerpDerp__FerpMerp do
            extend Bleeding::Action
            desc 'zerp'
          end

          specify do
            should be_action( desc: ['zerp'] )
          end
        end
      end
    end
  end
end
