module Skylab::Brazen

  class CollectionAdapters::GitConfig

    GitConfigMagnetic_ = ::Class.new Home_::Action  # in [#028]

    Magnetics = ::Module.new

    # ==

    class Magnetics::RetrieveEntity_via_EntityIdentifier_and_Document < GitConfigMagnetic_  # 1x

      Attributes_actor_.call( self,
        :entity_identifier,
        :document,
        :kernel,
      )

      def execute
        _ok = via_entity_identifier_resolve_subsection_id
        _ok && result_via_subsection_id__
      end
    end

    # ==

    class Magnetics::EntityStream_via_Collection < GitConfigMagnetic_

      Attributes_actor_.call( self,
        :model_class,
        :document,
        :kernel,
      )

      def initialize & p
        @listener = p
      end

      def execute
        __init_subsection_name_query
        __init_section_stream_via_subsection_name_query
        __stream_via_section_stream
      end

      def __init_subsection_name_query
        if @model_class
          __init_subsection_name_query_via_model_class
        else
          @_subsection_name_query = nil
          ACHIEVED_
        end
      end

      def __init_subsection_name_query_via_model_class

        sym = __subsection_name_symbol_via_model_class

        @_subsection_name_query = -> sect do
          sym == sect.external_normal_name_symbol
        end

        NIL
      end

      def __subsection_name_symbol_via_model_class
        @model_class.node_identifier.
          silo_name_symbol.id2name.gsub( UNDERSCORE_, DASH_ ).intern
      end

      def __init_section_stream_via_subsection_name_query
        if @_subsection_name_query.nil?
          __init_section_stream_as_stream_of_all_sections
        else
          __do_init_section_stream_via_subsection_name_query
        end
      end

      def __init_section_stream_as_stream_of_all_sections

        @_section_stream = @document.sections.to_stream_of_sections
        NIL
      end

      def __do_init_section_stream_via_subsection_name_query

        @_section_stream = @document.sections.to_stream_of_sections.reduce_by do |el|
          @_subsection_name_query.call el
        end
        NIL
      end

      def __stream_via_section_stream
        if @model_class
          __entity_stream_via_section_stream_and_model_class
        else
          @_section_stream
        end
      end

      def __entity_stream_via_section_stream_and_model_class

        fly = @model_class.new_flyweight @kernel, & @listener
        box = fly.properties
        name_name_s = NAME_SYMBOL.to_s

        @_section_stream.map_by do |sect|

          h = { name_name_s => sect.subsection_string }

          sect.assignments.each_normalized_pair do |sym, x|
            x or next
            h[ sym.id2name ] = "#{ x }"
          end

          box.replace_hash h
          fly
        end
      end
    end

    # ==

    class GitConfigMagnetic_
    private

      def via_entity_identifier_resolve_subsection_id
        __via_entity_identifier_resolve_both_strings
        via_both_strings_resolve_subsection_id_
      end

      def __via_entity_identifier_resolve_both_strings
        id = @entity_identifier
        @section_s = id.silo_name_symbol.id2name.gsub UNDERSCORE_, DASH_
        @subsection_s = id.entity_name_string ; nil
      end

      def via_entity_resolve_subsection_id__
        via_entity_resolve_model_class
        via_model_class_resolve_section_string
        via_entity_resolve_subsection_string
        via_both_strings_resolve_subsection_id_
      end

      def via_entity_resolve_subsection_id_via_entity_name s
        via_entity_resolve_model_class
        via_model_class_resolve_section_string
        @subsection_s = s
        via_both_strings_resolve_subsection_id_
      end

      def via_model_class_resolve_section_string
        @section_s = @model_class.
          node_identifier.silo_name_symbol.id2name.gsub UNDERSCORE_, DASH_ ; nil
      end

      def via_entity_resolve_subsection_string
        @subsection_s = @entity.natural_key_string ; nil
      end

      def via_both_strings_resolve_subsection_id_
        @subsection_id = Subsection_Identifier_.
          new @section_s, @subsection_s
        ACHIEVED_
      end

      def result_via_subsection_id__
        ok = via_subsection_id_resolve_section_
        ok &&= __via_subsection_id_resolve_model_class
        ok && __via_section_and_model_class_unmarshal
      end

      def via_subsection_id_resolve_section_

        count = 0
        found = false

        ss = @subsection_id
        st = @document.sections.to_stream_of_sections

        sect_sym = ss.section_s.intern
        ss_s = ss.subsection_s

        while sect = st.gets

          if sect_sym != sect.external_normal_name_symbol
            next
          end

          count += 1

          if ss_s != sect.subsection_string
            next
          end

          found = true
          @section = sect
          break
        end

        if found
          ACHIEVED_
        else
          @count = count
          maybe_send_event :error, :component_not_found do
            build_entity_not_found_event
          end
          UNABLE_
        end
      end

      def build_entity_not_found_event

        build_not_OK_event_with :component_not_found,
          :count, @count,
          :subsection_id, @subsection_id,
          :byte_upstream_reference, @document.byte_upstream_reference do |y, o|

          if o.byte_upstream_reference
            s = o.byte_upstream_reference.description_under self
            s and loc_s = " in #{ s }"
          end

          ss = o.subsection_id

          if o.count.zero?
            y << "found no #{ ick ss.section_s } section#{ loc_s }"
          else
            y << "no #{ ick ss.subsection_s } section found in #{
             }#{ o.count } #{ ss.section_s } section(s)#{ loc_s }"
          end
        end
      end

      def __via_subsection_id_resolve_model_class

        _sym = @subsection_id.to_silo_name_symbol

        _id = Home_::Nodesque::Identifier.via_symbol _sym

        silo = @kernel.silo_via_identifier _id, & @listener

        if silo
          @model_class = silo.silo_module
          ACHIEVED_
        end
      end

      def __via_section_and_model_class_unmarshal

        _x = @model_class.unmarshalled @kernel, @listener do |o|
          o.edit_pair @section.subsection_string, NAME_SYMBOL
          o.edit_pairs @section.assignments do | x |
            if ! x.nil?
              x.to_s  # life is easier if string is the great equalizer:
              # just because the collection thinks it's e.g. an int or a
              # boolean doesn't mean it "is"
            end
          end
        end

        _x  # hi. #todo
      end
    end

    # ==

    class Subsection_Identifier_

      def initialize s, ss
        @section_s = s ; @subsection_s = ss
        s = ss.dup
        Section_::Mutate_subsection_name_for_marshal[ s ]
        @escaped_subsection_s = s
      end


      def to_a
        [ @subsection_s, @section_s ]
      end

      def to_silo_name_symbol
        @section_s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def description
        "#{ @section_s } \"#{ @escaped_subsection_s }\""
      end

      attr_reader(
        :section_s,
        :subsection_s,
        :escaped_subsection_s,
      )
    end

    # ==
    # ==

    LINE_SEP_ = "\n".freeze

    # ==
  end
end
