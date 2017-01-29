module Skylab::TestSupport::TestSupport

  module Quickie

    def self.[] tcc
      tcc.include self
    end

    # -
      def subject_module_
        Home_::Quickie
      end
    # -
  end
end
# #born years later
