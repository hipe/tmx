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
        if s.frozen?
          @s = s
        else
          @s = s.dup.freeze
        end
      end

      def as_normal_string
        @s
      end
    end
  end
end
