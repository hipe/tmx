module Skylab::Brazen

  class Action_

    def initialize kernel
      @kernel = kernel
    end

    def name
      @name ||= Brazen_::Lib_::Name[].from_module self.class
    end

    def has_description
      ! self.class.description_block.nil?
    end

    def under_expression_agent_get_N_desc_lines expression_agent, d=nil
      Brazen_::CLI::N_Lines_.
        new( d, [ self.class.description_block ], expression_agent ).execute
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
  end
end
