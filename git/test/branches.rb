module Skylab::Git::TestSupport

  module Branches

    def self.[] tcc

      Common_.test_support::Want_Emission[ tcc ]
      tcc.include Instance_Methods___
    end

    module Instance_Methods___

      def subject_API
        Home_::API
      end
    end
  end
end
