module Skylab::Cull

  class Models_::Entity_

    # :+[#br-013]:API.A trailing underscore = not part of reactive model tree)

    class << self

      def via_structured_hash h
        new do | ent |
          ent.__init_with_structured_hash h
        end
      end
    end

    def initialize
      @actual_properties = []
      yield self
    end

    def members
      [ :actual_property_via_name_symbol, :get_property_name_symbols,
        :to_actual_property_stream, :to_even_iambic ]
    end

    def __init_with_structured_hash h
      h.each_pair do | sym, x |
        add_actual_property_value_and_name x, sym
      end
      nil
    end

    def add_actual_property_value_and_name x, sym
      a = @actual_properties
      a.push Actual_Property__.new( x, sym )
      nil
    end

    def express_into_under y, expag  # #todo: #not-covered (done visually only)
      st = to_actual_property_stream
      expag.calculate do
        prp = st.gets
        s_a = [ "(" ]
        if prp
          p = -> prp_ do
            "#{ prp.name.as_slug }: #{ val prp_.value_x }"
          end
          s_a.push p[ prp ]
          prp = st.gets
          while prp
            s_a.push ", #{ p[ prp ] }"
            prp = st.gets
          end
        end
        s_a.push ")"
        y << ( s_a * EMPTY_S_ )
      end
      ACHIEVED_
    end

    def at * i_a
      at_fields i_a
    end

    def at_fields i_a
      if i_a.length.zero?
        EMPTY_A_
      else
        h = ::Hash[ i_a.map { |i| [ i, true ] } ]
        h_ = {}
        @actual_properties.each do | prp |
          sym = prp.name_symbol
          h.delete sym or next
          h_[ sym ] = prp.value_x
          h.length.zero? and break
        end
        i_a.map { |i| h_[ i ] }
      end
    end

    def [] sym
      prp = actual_property_via_name_symbol sym
      prp and prp.value_x
    end

    def get_property_name_symbols
      @actual_properties.map do | prp |
        prp.name_symbol
      end
    end

    def to_actual_property_stream
      Callback_::Stream.via_nonsparse_array @actual_properties
    end

    def actual_property_via_name_symbol sym
      @actual_properties.detect do | prp |
        sym == prp.name_symbol
      end
    end

    def to_even_iambic
      a = []
      @actual_properties.each do | prp |
        a.push prp.name_symbol, prp.value_x
      end
      a
    end




    # ~ mutation API

    def remove_properties_at_indexes d_a

      range = 0 ... @actual_properties.length

      out_of_range = d_a.detect do | d |
        ! range.include?( d )
      end
      if out_of_range
        UNABLE_
      else
        d_a.each do | d |
          @actual_properties[ d ] = nil
        end
        @actual_properties.compact!
        ACHIEVED_
      end
    end

    def remove_property prp
      oid = prp.object_id
      d = @actual_properties.index do | prp_ |
        oid == prp_.object_id
      end
      if d
        @actual_properties[ d, 1 ] = EMPTY_A_
        ACHIEVED_
      else
        UNABLE_
      end
    end

    EMPTY_A_ = [].freeze

    class Actual_Property__

      def initialize x, sym
        @value_x = x
        @name_symbol = sym
      end

      def members
        [ :value_x, :name, :name_symbol ]
      end

      def name
        @nm ||= Callback_::Name.via_variegated_symbol @name_symbol
      end

      attr_reader :value_x, :name_symbol
    end
  end
end
