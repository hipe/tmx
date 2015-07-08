module Skylab::Git::TestSupport

  module Models::Branches::Support

    def self.[] tcc

      Callback_.test_support::Expect_event[ tcc ]
      tcc.include Instance_Methods___
    end

    module Instance_Methods___

      def subject_API
        Home_::API
      end
    end
  end
end
