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

    def get_one_line_description expression_agent
      One_Line__.new( expression_agent, self.class.description_block ).one_line
    end

    def get_description_lines expression_agent
      a = [] ; p = self.class.description_block
      expression_agent.calculate a, & p
      a
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

    class One_Line__
      def initialize expression_agent, p
        @exp = expression_agent ; @p = p
      end
      def one_line
        catch :done_with_one_line do
          @exp.instance_exec self, & @p
        end
      end
      def << line
        throw :done_with_one_line, line
      end
    end
  end
end
