module Skylab::Brazen

  class Data_Stores_::Git_Config

    Git_Config_Actor_ = ::Class.new Brazen_::Data_Store_::Actor  # in [#028]

    Actors__ = ::Module.new

    class Actors__::Retrieve < Git_Config_Actor_

      Actor_[ self, :properties,
        :entity_identifier, :model_class, :document,
        :event_receiver, :kernel ]

      def execute
        ok = via_entity_identifier_resolve_subsection_identifier
        ok && via_subsection_identifier_resolve_some_result
        ok && @result
      end
    end

    class Actors__::Scan < Git_Config_Actor_

      Actor_[ self, :properties,
        :model_class, :document,
        :event_receiver, :kernel ]

      def execute
        via_model_class_rslv_subsection_name_query
        via_subsection_name_query_rslv_section_scan
        via_section_scan_and_model_class_produce_entity_scan
      end

    private

      def via_model_class_rslv_subsection_name_query
        i = via_model_class_prdc_section_name_i
        @subsection_name_query = -> sect do
          i == sect.normalized_name_i
        end ; nil
      end

      def via_model_class_prdc_section_name_i
        @model_class.node_identifier.
          silo_name_i.id2name.gsub( UNDERSCORE_, DASH_ ).intern
      end

      def via_subsection_name_query_rslv_section_scan
        @section_scan = @document.sections.to_scan.reduce_by do |x|
          @subsection_name_query.call x
        end ; nil
      end

      def via_section_scan_and_model_class_produce_entity_scan
        fly = @model_class.new_flyweight @event_receiver, @kernel
        box = fly.properties
        name_name_s = NAME_.to_s
        @section_scan.map_by do |sect|
          h = { name_name_s => sect.subsect_name_s }
          sect.assignments.write_to_hash h
          box.replace_hash h
          fly
        end
      end
    end

    class Git_Config_Actor_
    private

      def via_entity_identifier_resolve_subsection_identifier
        via_entity_identifier_resolve_both_strings
        via_both_strings_resolve_subsection_identifier
      end

      def via_entity_identifier_resolve_both_strings
        id = @entity_identifier
        @section_string = id.silo_name_i.id2name.gsub UNDERSCORE_, DASH_
        @subsection_string = id.entity_name_s ; nil
      end

      def via_entity_resolve_subsection_identifier
        via_entity_resolve_model_class
        via_model_class_resolve_section_string
        via_entity_resolve_subsection_string
        via_both_strings_resolve_subsection_identifier
      end

      def via_model_class_resolve_section_string
        @section_string = @model_class.
          node_identifier.silo_name_i.id2name.gsub UNDERSCORE_, DASH_ ; nil
      end

      def via_entity_resolve_subsection_string
        @subsection_string = @entity.local_entity_identifier_string ; nil
      end

      def via_both_strings_resolve_subsection_identifier
        @subsection_identifier = Subsection_Identifier_.
          new @section_string, @subsection_string
        PROCEDE_
      end

      def via_subsection_identifier_resolve_some_result
        ok = via_subsection_identifier_resolve_section
        ok &&= via_subsection_identifier_resolve_model_class
        ok && via_section_and_model_class_resolve_result
        ok || @result = false
      end

      def via_subsection_identifier_resolve_section
        scan = @document.sections.to_scan
        ss = @subsection_identifier
        s_i = ss.section_s.intern ; ss_s = ss.subsection_s
        found = false ; count = 0
        while sect = scan.gets
          s_i == sect.normalized_name_i or next
          count += 1
          ss_s == sect.subsect_name_s or next
          found = true
          @section = sect
          break
        end
        if found
          ACHEIVED_
        else
          @count = count
          send_event build_entity_not_found_event
          UNABLE_
        end
      end

      def build_entity_not_found_event

        build_not_OK_event_with :entity_not_found,
          :count, @count,
          :subsection_identifier, @subsection_identifier,
          :document_locator, @document.identifier do |y, o|

          if o.document_locator
            s = o.document_locator.render_first_line_under self
            s and loc_s = " in #{ s }"
          end

          ss = o.subsection_identifier

          if o.count.zero?
            y << "found no #{ ick ss.section_s } section#{ loc_s }"
          else
            y << "no #{ ick ss.subsection_s } section found in #{
             }#{ o.count } #{ ss.section_s } section(s)#{ loc_s }"
          end
        end
      end

      def via_subsection_identifier_resolve_model_class
        _i = @subsection_identifier.to_silo_name_i
        _id = Node_Identifier_.via_symbol _i
        cols = @kernel.collections_via_identifier _id, @event_receiver
        if cols
          @model_class = cols.model_class
          ACHEIVED_
        end
      end

      def via_section_and_model_class_resolve_result
        x_a = [ NAME_, @section.subsect_name_s ]
        scan = @section.assignments.to_scan
        props = @model_class.properties
        while ast = scan.gets
          i = ast.normalized_name_i
          prop = props.fetch i
          if prop.takes_argument
            x = ast.value_x
            x_a.push i, x && "#{ x }"
          else
            if ast.value_x
              x_a.push i
            end
          end
        end
        entity = @model_class.unmarshalled @event_receiver, @kernel do |o|
          o.with_iambic x_a
        end  # :+[#037]
        @result = entity
        PROCEDE_
      end

      def resolve_result_via_write_file dry_run
        _pn = ::Pathname.new @to_path
        @result = @document.write_to_pathname _pn, :is_dry, @dry_run
      end
    end

    class Subsection_Identifier_

      def initialize s, ss
        @section_s = s ; @subsection_s = ss
        Section_.escape_subsection_name(
          @escaped_subsection_s = ss.dup )
      end

      attr_reader :section_s, :subsection_s, :escaped_subsection_s

      def to_a
        [ @section_s, @subsection_s ]
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
