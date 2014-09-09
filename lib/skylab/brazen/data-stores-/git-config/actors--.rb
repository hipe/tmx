module Skylab::Brazen

  class Data_Stores_::Git_Config

    class Git_Config_Actor_ < Data_Store_::Actor
    private

      def via_name_and_class_build_subsection_locator
        Subsection_Locator__.
          new Section_from_entity_class_[ @class ], "#{ @name_x }"
      end

      def resolve_document_for_write
        resolve_document_via_class Git_Config_::Mutable
      end

      def resolve_document_via_class cls
        error = nil
        @document = cls.parse_path @to_path do |ev|
          error = ev ; nil
        end
        if error
          resolve_result_via_parse_error error
          UNABLE_
        else
          PROCEDE_
        end
      end

      def via_document_and_ss_resolve_entity
        ok = via_document_and_ss_resolve_section
        ok && via_section_resolve_entity
      end

      def via_document_and_ss_resolve_section
        scan = @document.sections.to_scan
        s_i = @ss.section_s.intern ; ss_s = @ss.subsection_s
        found = false ; count = 0 ; @section = nil
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
          _ev = build_retrieve_error
          resolve_result_via_error _ev
          UNABLE_
        end
      end

      def send_retrieve_error
        _ev = build_retrieve_error
        send_error _ev
      end

      def build_retrieve_error
        build_event_with :entity_not_found,
          :description_s, @ss.to_description_s, :ss, @ss,
            :entity_class, @class, :ok, false,
              :count, @count do |y, o|
          if o.count.zero?
            y << "found no #{ ick o.ss.section_s } sections"
          else
            y << "no #{ ick o.ss.subsection_s } section found in #{
             }#{ o.count } #{ o.ss.section_s } section(s)"
          end
        end
      end

      def via_section_resolve_entity
        x_a = [ NAME_, @section.subsect_name_s ]
        scan = @section.assignments.to_scan
        props = @class.properties
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
        ent = @class.new @collection.kernel
        ok = ent.marshal_load x_a, -> ev do
          @result = @no_p[ ev ] ; UNABLE_
        end
        ok and @entity = ent
        ok
      end

      def resolve_result_via_parse_error ev
        x_a = ev.to_iambic
        x_a.push :ok, UNABLE_
        path_s = @to_path
        ev_ = build_event_via_iambic_and_message_proc x_a, -> y, o do
          instance_exec y_=[], ev, & ev.message_proc
          y << "failed to parse #{ pth path_s } - #{ y_ * LINE_SEP_ }"
        end
        resolve_result_via_error ev_ ; nil
      end

      def resolve_result_via_write_file dry_run
        @document.write_to_pathname ::Pathname.new( @to_path ),
          self, :is_dry, @dry_run, :channel, :the_document
        nil  # set your result in your callback
      end
    public
      def receive_the_document_wrote_file ev  # set result
        x_a = ev.to_iambic
        x_a.push :entity_verb_i, @verb_i
        ev_ = build_event_via_iambic x_a do |y, o|
          instance_exec y_=[], ev, & ev.message_proc
          y << "#{ o.entity_verb_i } entity. #{ y_ * LINE_SEP_ }"
        end
        delegate.receive_success_event ev_
        @result = ev.bytes ; nil
      end
    end

    module Actors__

      class Retrieve < Git_Config_Actor_

        Actor_[ self, :properties,
          :name_x, :class, :collection, :no_p ]

        def execute
          @to_path = @collection.to_path
          @ss = via_name_and_class_build_subsection_locator
          ok = rslv_document_for_read
          ok &&= via_document_and_ss_resolve_entity
          ok ? @entity : @result
        end

      private

        def rslv_document_for_read
          resolve_document_via_class Git_Config_
        end

        def resolve_result_via_error ev
          @result = @no_p[ ev ] ; nil
        end
      end
    end

    class Subsection_Locator__

      def initialize s, ss
        @section_s = s ; @subsection_s = ss
      end

      attr_reader :section_s, :subsection_s

      def to_a
        [ @section_s, @subsection_s ]
      end

      def to_description_s
        "#{ @section_s } #{ @subsection_s.inspect }"
      end
    end

    class Construe_subsection__ < Subsection_Locator__

      Actor_[ self, :properties, :entity ]

      def execute
        work
        @entity = nil
        freeze
      end

    private
      def work
        rslv_section
        rslv_subsection
      end

      def rslv_section
        @section_s = Section_from_entity_class_[ @entity.class ].freeze
      end

      def rslv_subsection
        @subsection_s = @entity.property_value( NAME_ ).dup.freeze ; nil
      end
    end

    Section_from_entity_class_ = -> cls do
      a = cls.full_name_function
      a_ = ::Array.new a.length
      a_[0] = a.first.as_slug.gsub( /-|s-\z/, EMPTY_S_ )
      a_[1..-1] = a[1..-1].map( & :as_slug )
      a_ * '-'
    end

    LINE_SEP_ = "\n".freeze
  end
end
