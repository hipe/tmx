require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI

  describe "#{ TanMan::CLI::Action } failed_sentence" do

    sentence = TanMan::CLI::Action.failed_sentence

    define_singleton_method :o do |a, s, *t|
      it "#{ s }", *t do
        ao = sentence[ a ]
        so = ao.join ' '
        so.should eql s
      end
    end

    o ['tanman', 'service', 'external', 'trepidatious', 'connection', 'delete'],
       "tanman trepidatious external service failed to delete connection"

    o ['tanman', 'internationalization', 'language', 'preference', 'set'],
       "tanman language internationalization failed to set preference"

    o ['tanman', 'graph', 'example', 'set'],
       "tanman graph failed to set example"

    o ['tanman', 'remote', 'add'],
      "tanman failed to add remote"

    o ['taman', 'add'],
      "taman failed to add"

    o ['tanman'],
      "tanman failed"

    o [],
      ''
  end


  describe "#{ TanMan::CLI::Action } inflect_failure_reason" do
    extend CLI_TestSupport

    klass :Action, extends: TanMan::CLI::Action do |o|
      self::ANCHOR_MODULE = o.Actions
    end

    modul :Actions do
      @dir_path = :nope
      extend TanMan::Boxxy
    end


    event_struct = ::Struct.new :message

    event = event_struct[ 'derp' ].freeze

    context "with 'tanman/add'" do

      klass :Actions__Add, extends: :Action do
      end

      it "tanmun failed to add - derp" do
        s = action.inflect_failure_reason event
        s.should eql('tanmun failed to add - derp')
      end
    end


    context "with a 5 level deep action'" do

      klass :Actions__Beats__Dubstep__WOBBLING__Pokey__Impress, extends: :Action do
      end

      expect = "tanmun wobbling dubstep beats failed to impress pokey - derp"

      it expect do
        action = self.action
        s = action.inflect_failure_reason event
        s.should eql(expect)
      end
    end
  end
end
