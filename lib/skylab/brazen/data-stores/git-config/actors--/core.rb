module Skylab::Brazen

  class Data_Stores::Git_Config

    Git_Config_Actor_ = ::Class.new Brazen_::Data_Store_::Actor  # in [#028]

    Actors__ = ::Module.new

    class Actors__::Retrieve < Git_Config_Actor_

      Actor_.call self, :properties,
        :entity_identifier,
        :document,
        :kernel

      def execute
        ok = via_entity_identifier_resolve_subsection_id
        ok && via_subsection_id_resolve_some_result
        ok && @result
      end
    end

    class Actors__::Build_stream < Git_Config_Actor_

      Actor_.call self, :properties,
        :model_class,
        :document,
        :kernel

      def execute
        rslv_subsection_name_query
        via_any_subsection_name_query_rslv_section_scan
        via_section_scan_produce_scan
      end

    private

      def rslv_subsection_name_query
        if @model_class
          via_model_class_rslv_subsection_name_query
        else
          @subsection_name_query = nil
          ACHIEVED_
        end
      end

      def via_model_class_rslv_subsection_name_query
        i = via_model_class_prdc_section_name_i
        @subsection_name_query = -> sect do
          i == sect.external_normal_name_symbol
        end ; nil
      end

      def via_model_class_prdc_section_name_i
        @model_class.node_identifier.
          silo_name_i.id2name.gsub( UNDERSCORE_, DASH_ ).intern
      end

      def via_any_subsection_name_query_rslv_section_scan
        if @subsection_name_query.nil?
          when_all_rslv_section_scan
        else
          via_subsection_name_query_rslv_section_scan
        end
      end

      def when_all_rslv_section_scan
        @section_scan = @document.sections.to_stream ; nil
      end

      def via_subsection_name_query_rslv_section_scan
        @section_scan = @document.sections.to_stream.reduce_by do |x|
          @subsection_name_query.call x
        end ; nil
      end

      def via_section_scan_produce_scan
        if @model_class
          via_section_scan_and_model_class_produce_entity_scan
        else
          @section_scan
        end
      end

      def via_section_scan_and_model_class_produce_entity_scan
        fly = @model_class.new_flyweight @kernel, & @on_event_selectively
        box = fly.properties
        name_name_s = NAME_.to_s
        @section_scan.map_by do |sect|
          h = { name_name_s => sect.subsect_name_s }
          sect.assignments.each_normalized_pair do |i, x|
            x or next
            h[ i.id2name ] = "#{ x }"
          end
          box.replace_hash h
          fly
        end
      end
    end

    class Git_Config_Actor_
    private

      def via_entity_identifier_resolve_subsection_id
        __via_entity_identifier_resolve_both_strings
        via_both_strings_resolve_subsection_id_
      end

      def __via_entity_identifier_resolve_both_strings
        id = @entity_identifier
        @section_s = id.silo_name_i.id2name.gsub UNDERSCORE_, DASH_
        @subsection_s = id.entity_name_s ; nil
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
          node_identifier.silo_name_i.id2name.gsub UNDERSCORE_, DASH_ ; nil
      end

      def via_entity_resolve_subsection_string
        @subsection_s = @entity.natural_key_string ; nil
      end

      def via_both_strings_resolve_subsection_id_
        @subsection_id = Subsection_Identifier_.
          new @section_s, @subsection_s
        PROCEDE_
      end

      def via_subsection_id_resolve_some_result
        ok = via_subsection_id_resolve_section_
        ok &&= __via_subsection_id_resolve_model_class
        ok && __via_section_and_model_class_resolve_unmarshal_result
        ok || @result = false
      end

      def via_subsection_id_resolve_section_
        scan = @document.sections.to_stream
        ss = @subsection_id
        s_i = ss.section_s.intern ; ss_s = ss.subsection_s
        found = false ; count = 0
        while sect = scan.gets
          s_i == sect.external_normal_name_symbol or next
          count += 1
          ss_s == sect.subsect_name_s or next
          found = true
          @section = sect
          break
        end
        if found
          ACHIEVED_
        else
          @count = count
          maybe_send_event :error, :entity_not_found do
            build_entity_not_found_event
          end
          UNABLE_
        end
      end

      def build_entity_not_found_event

        build_not_OK_event_with :entity_not_found,
          :count, @count,
          :subsection_id, @subsection_id,
          :input_id, @document.input_id do |y, o|

          if o.input_id
            s = o.input_id.description_under self
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
        _i = @subsection_id.to_silo_name_i
        _id = Node_Identifier_.via_symbol _i
        silo = @kernel.silo_via_identifier _id, & @on_event_selectively
        if silo
          @model_class = silo.model_class
          ACHIEVED_
        end
      end

      def __via_section_and_model_class_resolve_unmarshal_result

        @result = @model_class.unmarshalled @kernel, @on_event_selectively do |o|
          o.edit_pair @section.subsect_name_s, NAME_
          o.edit_pairs @section.assignments do | x |
            if ! x.nil?
              x.to_s  # life is easier if string is the great equalizer:
              # just because the datastore thinks it's e.g. an int or a
              # boolean doesn't mean it "is"
            end
          end
        end

        @result and PROCEDE_
      end

      def resolve_result_via_write_file dry_run
        @result = @document.write_to_path @to_path, :is_dry, @dry_run
      end
    end

    class Subsection_Identifier_

      def initialize s, ss
        @section_s = s ; @subsection_s = ss
        Section_.mutate_subsection_name_for_marshal(
          @escaped_subsection_s = ss.dup )
      end

      def members
        [ :section_s, :subsection_s, :escaped_subsection_s ]
      end

      attr_reader :section_s, :subsection_s, :escaped_subsection_s

      def to_a
        [ @subsection_s, @section_s ]
      end

      def to_silo_name_i
        @section_s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def description
        "#{ @section_s } \"#{ @escaped_subsection_s }\""
      end
    end

    LINE_SEP_ = "\n".freeze
  end
end
