module Skylab::Brazen

  module Property

    # (mostly property-related events, and a semantic branch node)

    class << self

      def build_ambiguous_property_event *a, & slug
        Home_.lib_.fields::Events::Ambiguous.new_via_arglist a, & slug
      end

      def build_extra_values_event *a
        Home_.lib_.fields::Events::Extra.new_via_arglist a
      end

      def build_missing_required_properties_event *a
        Home_.lib_.fields::Events::Missing.new_via_arglist a
      end
    end # >>

    Property_ = self
  end
end
