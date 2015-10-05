module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::SHA  # :[#012]:#what-is-the-deal-with-SHA's?

      class << self

        def via_normal_string s
          new s
        end

        private :new
      end  # >>

      def initialize s
        @string = if s.frozen?
          s
        else
          s.dup.freeze
        end
      end

      attr_reader :string
    end
  end
end
