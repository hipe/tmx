require_relative 'test-support'

module Skylab::Headless::TestSupport::NLP::EN::AAIH

  ::Skylab::Headless::TestSupport::NLP::EN[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  describe "[hl] NLP EN API action inflection hack (the class using it..)" do

    extend TS_

    TestSupport_::Quickie.apply_experimental_specify_hack self

    before :all do

      class MyAction
        extend Headless_::NLP::EN::API_Action_Inflection_Hack
      end

      module MyWidget # a noun
        class List < MyAction # a verb
          inflection.inflect.noun :plural
        end
        class Add < MyAction # a verb
        end
      end
    end

    it "gets an inflection knobby" do
      [ MyAction.inflection.object_id,
        MyAction.inflection.object_id,
  MyWidget::List.inflection.object_id,
   MyWidget::Add.inflection.object_id
      ].uniq.length.should eql(3)
    end

    context "that, assuming that actions are named after verbs" do

      context "infers what the verb is and lets you inflect on it" do

        context "e.g. with #add" do

          let :klass do
            MyWidget::Add
          end

          context "the progressive form of it" do

            let :subject do
              klass.inflection.lexemes.verb.progressive
            end

            specify do
              should eql 'adding'
            end
          end
        end
      end
    end

    context("and further assuming that the surround modules of said actions",
      "are named after nouns, and you tell it which verbs deal with single or plural nouns") do

      let :subject do
        "#{ inflection.lexemes.verb.progressive } #{ inflection.inflected.noun }"
      end

      context "compare the inflection for LIST:" do
        let(:inflection) { MyWidget::List.inflection }
        specify { should eql("listing my widgets") }
      end

      context "with that of ADD:" do
        let(:inflection) { MyWidget::Add.inflection }
        specify { should eql("adding my widget") }
      end

      context "it's dumb to ask the base class for its inflection ",
        "but let's see what happens" do
        let(:inflection) { MyAction.inflection }
          specify { should eql("my actioning aaih") }  # AAIH -> this module
      end
    end
  end

  describe "[hl] the industrious action class" do
    extend TS_

    TestSupport_::Quickie.apply_experimental_specify_hack self

    before :all do

      class MyAwesomeAction
        extend Headless_::NLP::EN::API_Action_Inflection_Hack
      end

      module Flugelhorn
        class Show < MyAwesomeAction
          inflection.inflect.noun :plural
        end
        class Edit < MyAwesomeAction
          inflection.inflect.noun :singular
        end
        class TheDerpAction < MyAwesomeAction

        end
      end
    end

    let :subject do
      action.inflection.inflected.noun
    end

    it "when specified as singular" do
      action = Flugelhorn::Edit
      action.inflection.inflected.noun.should eql('flugelhorn')
    end

    context "when specified as plural" do
      let(:action) { Flugelhorn::Show }
      specify { should eql("flugelhorns") }
    end

    context "when not specified it will use the singular" do
      let(:action) { Flugelhorn::TheDerpAction }
      specify { should eql(action.inflection.lexemes.noun.singular) }
    end
  end
end
