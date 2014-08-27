module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Actors__

      class Persist

        Brazen_::Model_::Actor[ self, :properties,
          :entity,
          :collection,
          :kernel ]

        Entity_[]::Event::Merciless_Prefixing_Sender[ self ]

        def execute
          @to_path = @collection.to_path ; @collection = nil
          ok = prepare_values
          ok &&= parse_file
          ok &&= edit_file
          ok && write_file
          @result
        end

      private

        def prepare_values
          prepare_action_properties
          i_a = @entity.class.properties.get_names
          i_a.sort!
          y = []
          i_a.each do |i|
            x = @entity.property_value i
            x.nil? and next
            y.push Property__.new( i, x )
          end
          if y.length.zero?
            cannot_persist_entity_with_no_properties
          else
            @property_a = y
            PROCEDE_
          end
        end
        Property__ = ::Struct.new :name_i, :value_x

        def cannot_persist_entity_with_no_properties
          finish_with_error :cannot_persist_entity_with_no_properties,
            :entity, @entity, :is_positive, false
          UNABLE_
        end

        def prepare_action_properties
          @dry_run = @entity.action_property_value :dry_run ; nil
        end

        def parse_file
          error = nil
          @document = Git_Config_::Mutable.parse_path @to_path do |ev|
            error = ev ; nil
          end
          if error
            process_error error
            UNABLE_
          else
            PROCEDE_
          end
        end

        def process_error ev
          x_a = ev.to_iambic
          x_a.push :is_positive, false
          path_s = @to_path
          ev_ = Entity_[]::Event.inline_via_x_a_and_p x_a, -> y, o do
            instance_exec y_=[], ev, & ev.message_proc
            y << "failed to parse #{ pth path_s } - #{ y_ * LINE_SEP_ }"
          end
          finish_with_error_event ev_ ; nil
        end

        def edit_file
          @ss = Construe_subsection__[ @entity ]
          @section = @document.sections.touch_section( * @ss.to_a )
          if @section.is_empty
            edit_file_via_create_section
          else
            edit_file_via_update_section
          end
        end

        def edit_file_via_create_section
          @verb_i = :created
          write_section
        end

        def edit_file_via_update_section
          @verb_i = :updated
          y = get_section_body_lines
          @section.clear_section
          write_section
          y_ = get_section_body_lines
          if y == y_
            when_no_change_in_section
            UNABLE_
          else
            write_section
          end
        end

        def get_section_body_lines
          scn = @section.get_body_line_scanner
          y = [] ; x = nil ; y.push x while x = scn.gets ; y
        end

        def when_no_change_in_section
          finish_with_error :no_change_in_entity,
            :entity_description, @ss.to_description_s,
            :entity, @entity, :is_positive, false
        end

        def write_section
          @property_a.each do |prop|
            @section[ prop.name_i ] = prop.value_x
          end
          ACHEIVED_
        end

        def write_file
          @result = @document.write_to_pathname ::Pathname.new( @to_path ),
            self, :is_dry, @dry_run, :channel, :the_document ; nil
        end

        def receive_the_document_wrote_file ev
          x_a = ev.to_iambic
          x_a.push :entity_verb_i, @verb_i
          ev_ = build_event_with_iambic_and_p x_a, -> y, o do
            instance_exec y_=[], ev, & ev.message_proc
            y << "#{ o.entity_verb_i } entity. #{ y_ * LINE_SEP_ }"
          end
          @entity.receive_success_event ev_
        end

        def finish_with_error * x_a, & p
          _ev = build_event_with_iambic_and_p x_a, p
          finish_with_error_event _ev
        end

        def build_event_with_iambic_and_p x_a, p
          Entity_[]::Event.inline_via_x_a_and_p x_a, p
        end

        def finish_with_error_event ev
          @result = @entity.receive_error_event ev ; nil
        end
      end

      class Construe_subsection__

        Brazen_::Model_::Actor[ self, :properties, :entity ]

        def execute
          work
          @entity = nil
          freeze
        end

        def to_a
          [ @section_s, @subsection_s ]
        end

        def to_description_s
          "#{ @section_s } #{ @subsection_s.inspect }"
        end
      private
        def work
          rslv_section
          rslv_subsection
        end

        def rslv_section
          a = @entity.class.full_name_function
          a_ = ::Array.new a.length
          a_[0] = a.first.as_slug.gsub( /-|s-\z/, EMPTY_S_ )
          a_[1..-1] = a[1..-1].map( & :as_slug )
          @section_s = ( a_ * '-' ).freeze ; nil
        end

        def rslv_subsection
          @subsection_s = @entity.property_value( :name ).dup.freeze ; nil
        end
      end

      LINE_SEP_ = "\n".freeze
    end
  end
end
