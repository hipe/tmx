require_relative '../../core'

Skylab::Porcelain::En::ApiActionInflectionHack # force/test autolaod (mandatory) :(

module Skylab::Porcelain::En
  module TestSupport
    class MyAction
      extend ApiActionInflectionHack
      def self.inflect_noun stems
        'list' == stems.verb ? stems.noun.plural : stems.noun
      end
    end
    module MyWidget # a noun
      class List < MyAction # a verb
      end
      class Add < MyAction # a verb
      end
    end
  end
end

module Skylab::Porcelain::En
  include TestSupport

  describe "the class that extends #{ApiActionInflectionHack}" do
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
            subject { klass.inflection.stems.verb.progressive }
            specify { should eql('adding') }
          end
        end
      end
    end
    context("and further assuming that the surround modules of said actions",
      "are named after nouns, and you tell it which verbs deal with single or plural nouns") do
      subject { "#{inflection.stems.verb.progressive} #{inflection.inflected.noun}" }
      context "compare the inflection for LIST:" do
        let(:inflection) { MyWidget::List.inflection }
        specify { should eql("listing my widgets") }
      end
      context "with that of ADD:" do
        let(:inflection) { MyWidget::Add.inflection }
        specify { should eql("adding my widget") }
      end
      context("it's dumb to ask the base class for its inflection",
        "but let's see what happens") do
        let(:inflection) { MyAction.inflection }
        specify { should eql("my actioning test support") }
      end
   end
 end
end

