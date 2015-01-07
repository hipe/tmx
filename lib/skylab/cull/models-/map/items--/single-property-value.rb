module Skylab::Cull

  class Models_::Map

    class Items__::Single_property_value

      class << self

        def curry
          -> prp_name_string do
            new prp_name_string
          end
        end
      end

      def initialize prp_name_string
        @prp_name_sym = prp_name_string.intern
      end

      def [] ent
        ent[ @prp_name_sym ] || EMPTY_S_  # false-ish doesn't play nice with streams
      end
    end
  end
end
