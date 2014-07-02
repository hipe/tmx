module Skylab::Brazen

  class Action_

    def initialize kernel
      @kernel = kernel
    end

    def name
      @name ||= Brazen_::Lib_::Name[].from_module self.class
    end

    def get_one_line_description expression_agent
      One_Line__.new( expression_agent, self.class.description_block ).one_line
    end

    def self.desc &p
      @description_block = p ; nil
    end

    class << self
      attr_reader :description_block
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
      def puts line
        throw :done_with_one_line, line
      end
    end
  end
end
