require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] concerns - name - sessions - deep action isomorphicism for EN" do

    it "loads" do
      subject
    end

    class << self
      def o a, expected_s, * tag_a
        it "#{ expected_s }", * tag_a do
          _expect_X_from_Y expected_s, a
        end
      end
    end

    it "(the empty array of slugs yields the empty string)" do
      _expect_X_from_Y Brazen_::EMPTY_S_, Brazen_::EMPTY_A_
    end

    o [ 'tanman' ],
       "tanman failed"

    o [ 'tanman', 'add' ],
       "tanman failed to add"

    o [ 'tanman', 'remote', 'add' ],
       "tanman failed to add remote"

    o [ 'tanman', 'graph', 'starter', 'set' ],
       "tanman failed to set graph starter"

    o [ 'tanman', 'internationalization', 'language', 'preference', 'set' ],
       "tanman failed to set internationalization language preference"

    o [ 'tanman', 'services', 'external', 'trepidatious', 'connection', 'delete' ],
       "tanman trepidatious external services failed to delete connection"

    def _expect_X_from_Y expected_s, a
      ( subject.new( a ).to_string_array_for_failed * Brazen_::SPACE_  ).
        should eql expected_s
    end

    def subject

      Brazen_::Concerns_::Name::Sessions_::Deep_Action_Isomorphicism_for_EN
    end
  end
end
