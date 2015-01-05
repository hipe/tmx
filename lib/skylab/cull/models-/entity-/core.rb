module Skylab::Cull

  class Models_::Entity_

    Actions = ::Module.new  # no actions

    class << self

      def via_structured_hash h
        new do | ent |
          ent.__init_with_structured_hash h
        end
      end
    end

    def initialize
      @_index_of_last_seen = {}
      @actual_properties = []
      yield self
    end

    def members
      [ :get_property_name_symbols, :to_actual_property_stream, :to_even_iambic ]
    end

    def __init_with_structured_hash h
      h.each_pair do | sym, x |
        add_actual_property_value_and_name x, sym
      end
      nil
    end

    def add_actual_property_value_and_name x, sym

      a = @actual_properties

      @_index_of_last_seen[ sym ] = a.length

      a.push Actual_Property__.new( x, sym )

      nil
    end

    def render_all_lines_into_under y, expag  # #todo: #not-covered (done visually only)
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

    def [] sym
      prp = @actual_properties.detect do | prp_ |
        sym == prp_.name_symbol
      end
      prp and prp.value_x
    end

    def get_property_name_symbols
      @actual_properties.map do | prp |
        prp.name_symbol
      end
    end

    def to_actual_property_stream
      Callback_.stream.via_nonsparse_array @actual_properties
    end

    def to_even_iambic
      a = []
      @actual_properties.each do | prp |
        a.push prp.name_symbol, prp.value_x
      end
      a
    end

    def at_ i_a
      a = @actual_properties
      h = @_index_of_last_seen
      i_a.map do | sym |
        ( a.fetch h.fetch sym ).value_x
      end
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
