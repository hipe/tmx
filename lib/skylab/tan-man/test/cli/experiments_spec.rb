require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI

  describe "[tm] CLI::Action failed_sentence", wip: true do

    def self.o a, s, *t
      it "#{ s }", *t do
        out_a = TanMan_::CLI::Action.assemble_failed_a a
        out_s = out_a * ' '
        out_s.should eql( s )
      end
    end

    o [],
      ''

    o ['tanman'],
       "tanman failed"

    o ['taman', 'add'],
       "taman failed to add"

    o ['tanman', 'remote', 'add'],
       "tanman failed to add remote"

    o ['tanman', 'graph', 'starter', 'set'],
       "tanman failed to set graph starter"

    o ['tanman', 'internationalization', 'language', 'preference', 'set'],
       "tanman failed to set internationalization language preference"

    o ['tanman', 'services', 'external', 'trepidatious', 'connection', 'delete'],
       "tanman trepidatious external services failed to delete connection"
  end

  describe "[tm] CLI::Action inflect_failure_reason", wip: true do

    extend TS_

    if false
    klass :Action, extends: TanMan_::CLI::Action do |o|
      self::ACTIONS_ANCHOR_MODULE = o.Actions
    end

    modul :Actions do
      @dir_pathname = :nope
      # #was-boxxy
    end
    end

    event_struct = ::Struct.new :message

    event = event_struct[ 'derp' ].freeze

    context "with 'tanman/add'" do

      if false
      klass :Actions__Add, extends: :Action do
      end
      end

      it "tanmun failed to add - derp" do
        action = self.action
        s = action.send :inflect_failure_reason, event
        s.should eql('tanmun failed to add - derp')
      end
    end

    context "with a 5 level deep action'" do

      if false
      klass :Actions__Beats__Dubstep__WOBBLING__Pokey__Impress, extends: :Action do
      end
      end

      expect = "tanmun wobbling dubstep beats failed to impress pokey - derp"

      it expect do
        action = self.action
        s = action.send :inflect_failure_reason, event
        s.should eql(expect)
      end
    end
  end
end
