module Skylab::Brazen

  module Property

    # (mostly property-related events, and a semantic branch node)

    class << self

      def build_ambiguous_property_event *a
        Property_::Events::Ambiguous.new_via_arglist a
      end

      def build_extra_values_event *a
        Property_::Events::Extra.new_via_arglist a
      end

      def build_missing_required_properties_event *a
        Property_::Events::Missing.new_via_arglist a
      end
    end # >>

    DEFAULT_PROPERTY_LEMMA_ = 'property'.freeze

    Autoloader_[ Events = ::Module.new ]

    Property_ = self
  end
end
