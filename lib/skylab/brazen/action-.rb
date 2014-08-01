module Skylab::Brazen

  class Action_

    include Brazen_::Entity_  # so we can override its behavior near events

    def initialize
    end

    def name
      @name ||= Brazen_::Lib_::Name[].from_module self.class
    end

    def has_description
      ! self.class.description_block.nil?
    end

    def under_expression_agent_get_N_desc_lines expression_agent, d=nil
      Brazen_::Lib_::N_lines[].
        new( [], d, [ self.class.description_block ], expression_agent ).
         execute
    end

    def self.desc &p
      @description_block = p ; nil
    end

    class << self
      attr_reader :description_block
    end

    def get_property_scanner
      props = self.class.properties
      if props
        props.to_value_scanner
      else
        Callback_::Scn.the_empty_scanner
      end
    end

    def invoke_via_iambic_and_client_adapter x_a, client_adapter
      @client_adapter = client_adapter
      @error_count = 0
      process_iambic_fully x_a
      notificate :iambic_normalize_and_validate
      @error_count.zero? and execute
    end

    def on_error_channel_missing_required_props_entity_structure ev
      on_error_channel_entity_structure ev
    end

    def on_error_channel_entity_structure ev
      @error_count += 1
      @client_adapter.on_error_channel_entity_structure ev ; nil
    end
  end
end
