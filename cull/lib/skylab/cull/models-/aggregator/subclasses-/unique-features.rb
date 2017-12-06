module Skylab::Cull

  class Models_::Aggregator

    class Items__::Unique_features

      class << self

        def curry
          -> s do
            new s
          end
        end
      end  # >>

      def initialize s
        md = /\Aname field:[ \t]*/.match s
        @name_field_sym = md.post_match.intern
      end

      def [] estream, & p

        @listener = p  # meh

        h = {}  # feature_occurrence_entity_name_symbol_a_h

        name_field_sym = @name_field_sym

        ent = estream.gets
        cache = []
        while ent
          st = ent.to_actual_property_stream
          name_string = nil
          prp = st.gets
          while prp
            if name_field_sym == prp.name_symbol
              name_string = prp.value
            else
              cache.push prp
            end
            prp = st.gets
          end

          cache.each do | prp_ |
            sym = prp_.name_symbol
            h.fetch sym do
              h[ sym ] = []
            end.push Occurrence__.new( prp_, name_string )
          end
          cache.clear
          ent = estream.gets
        end

        __via_raw_hash h
      end

      Occurrence__ = ::Struct.new :prop, :entity_name_string

      def __via_raw_hash h

        of_entity_unique_features_h = {}

        h.each_pair do | feature_sym, occurrence_a |
          d = occurrence_a.length
          if 1 == d
            occurrence = occurrence_a.first
            of_entity_unique_features_h.fetch occurrence.entity_name_string do
              of_entity_unique_features_h[ occurrence.entity_name_string ] = []
            end.push (
              ( Home_::Models_::Entity_.new do | ent |
                ent.add_actual_property_value_and_name(
                  occurrence.entity_name_string,
                  :"entity name" )

                ent.add_actual_property_value_and_name(
                  occurrence.prop.name_symbol,
                  :"feature name" )

                ent.add_actual_property_value_and_name(
                  occurrence.prop.value,
                  :"feature value" )
              end ) )
          end
        end

        final_a = []

        of_entity_unique_features_h.each_value do | a |
          final_a.concat a
        end

        Stream_[ final_a ]
      end
    end
  end
end
