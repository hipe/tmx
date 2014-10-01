require_relative 'test-support'

module Skylab::Headless::TestSupport::NLP::EN

  class MyAction
    include CONSTANTS
    extend Headless_::NLP::EN::API_Action_Inflection_Hack
  end
  module MyWidget # a noun
    class List < MyAction # a verb
      inflection.inflect.noun :plural
    end
    class Add < MyAction # a verb
    end
  end

  describe "[hl] NLP EN API action inflection hack (the class using it..)" do

    extend TS_

    it "gets an inflection knobby" do
      [ MyAction.inflection.object_id,
        MyAction.inflection.object_id,
  MyWidget::List.inflection.object_id,
   MyWidget::Add.inflection.object_id
      ].uniq.length.should eql(3)
    end



    context "that, assuming that actions are named after verbs" do
      context "infers what the verb is and lets you inflect on it" do
        context "e.g. with #{MyWidget::Add}" do
          let(:klass) { MyWidget::Add }
          context "the progressive form of it" do
            subject { klass.inflection.lexemes.verb.progressive }
            specify { should eql('adding') }
          end
        end
      end
    end


    context("and further assuming that the surround modules of said actions",
      "are named after nouns, and you tell it which verbs deal with single or plural nouns") do
      subject { "#{inflection.lexemes.verb.progressive} #{inflection.inflected.noun}" }
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
         specify { should eql("my actioning en") }
      end
    end
  end


  describe "the industrious action class" do
    extend TS_

    klass :MyAwesomeAction do
      extend Headless_::NLP::EN::API_Action_Inflection_Hack
    end
    klass :Flugelhorn__Show, extends: :MyAwesomeAction do
      inflection.inflect.noun :plural
    end
    klass :Flugelhorn__Edit, extends: :MyAwesomeAction do
      inflection.inflect.noun :singular
    end
    klass :Flugelhorn__TheDerpAction, extends: :MyAwesomeAction
    let(:subject) do
      action.inflection.inflected.noun
    end
    it "when specified as singular" do
      action = _Flugelhorn__Edit
      action.inflection.inflected.noun.should eql('flugelhorn')
    end
    context "when specified as plural" do
      let(:action) { Flugelhorn__Show() }
      specify { should eql("flugelhorns") }
    end
    context "when not specified it will use the singular" do
      let(:action) { Flugelhorn__TheDerpAction() }
      specify { should eql(action.inflection.lexemes.noun.singular) }
    end
  end
end
