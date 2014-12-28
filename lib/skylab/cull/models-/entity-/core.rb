module Skylab::Cull

  class Models_::Entity_

    Actions = ::Module.new  # no actions

    def initialize
      @_index_of_last_seen = {}
      @actual_properties = []
      yield self
    end

    def members
      [ :actual_properties, :to_even_iambic ]
    end

    def add_actual_property_value_and_name s, sym

      a = @actual_properties

      @_index_of_last_seen[ sym ] = a.length

      a.push Actual_Property__.new( s, sym )

      nil
    end

    def to_even_iambic
      a = []
      @actual_properties.each do | prp |
        a.push prp.property_symbol, prp.actual_value_s
      end
      a
    end

    def at_ i_a
      a = @actual_properties
      h = @_index_of_last_seen
      i_a.map do | sym |
        ( a.fetch h.fetch sym ).actual_value_s
      end
    end

    class Actual_Property__

      def initialize s, sym
        @actual_value_s = s
        @property_symbol = sym
      end

      def members
        [ :actual_value_s, :property_symbol ]
      end

      attr_reader :actual_value_s, :property_symbol
    end
  end
end
