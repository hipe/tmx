module Skylab::Brazen

  class Action_

    class << self

      def name_function
        @nf ||= begin
          extend Lib_::Name_function_methods[]
          bld_name_function
        end
      end
    end

    include Brazen_::Model_::Entity  # so we can override its behavior near events

    def initialize
    end

    def name
      self.class.name_function
    end

    def has_description
      ! self.class.description_block.nil?
    end

    def under_expression_agent_get_N_desc_lines expression_agent, d=nil
      Brazen_::Lib_::N_lines[].
        new( [], d, [ self.class.description_block ], expression_agent ).
         execute
    end

    class << self
      attr_accessor :custom_inflection, :description_block
    end

    def to_even_iambic
      scn = get_property_scanner ; x_a = []
      while (( prop = scn.gets ))
        x_a.push prop.name.as_lowercase_with_underscores_symbol,
          instance_variable_get( prop.as_ivar )
      end
      x_a
    end

    def get_property_scanner
      props = self.class.properties
      if props
        props.to_value_scanner
      else
        Callback_::Scn.the_empty_scanner
      end
    end

    def produce_adapter_via_iambic_and_adapter x_a, adapter
      @client_adapter = adapter
      @error_count = 0
      process_iambic_fully x_a
      notificate :iambic_normalize_and_validate
      @error_count.zero? and @client_adapter
    end

    def on_missing_required_props ev
      on_negative_event ev
    end

    def on_error_event ev  # e.g ad-hoc normalization failure from spot [#012]
      ev_ = listener.sign_event ev
      on_negative_event ev_
    end

    def on_negative_event ev
      @error_count += 1
      @client_adapter.on_negative_event ev ; nil
    end

    private

    # ~

    def listener
      @listener ||= bld_listener
    end

    def bld_listener
      self.class::Listener.new @client_adapter, self.class
    end
  end
end
