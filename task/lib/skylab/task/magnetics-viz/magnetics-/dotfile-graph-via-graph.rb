class Skylab::Task

  module MagneticsViz

    class Magnetics_::DotfileGraph_via_Graph

      def initialize graph, & oes_p

        @graph = graph
        @_name_registry = Name_Registry___.new
        @_oes_p = oes_p
      end

      def execute
        self  # for now
      end

      def express_into_under y, expag
        dup.__etc y, expag
      end

      def __etc y, exp
        @expression_agent = exp
        @yielder = y
        y << "digraph g {\n"
        y << "}\n"
      end

      def to_association_stream

        @graph.to_waypoint_stream.expand_by do |wp|

          st = wp.to_association_stream.map_by do |asc|

            Association___.new asc, @_name_registry
          end

          if wp.has_only_one_means
            st
          else
            ::Kernel._B
            a = _.to_a
            Common_::Stream.via_nonsparse_array a
          end
        end
      end

      def to_node_stream

        nr = @_name_registry

        seen = {}
        first = -> s do
          seen.fetch s do
            seen[ s ] = false
            true
          end
        end

        @graph.to_waypoint_stream.expand_by do |wp|

          a = []

          if wp.has_only_one_means
            me = wp.only_means
            s = me.waypoint_slug
            if first[ s ]
              a.push Node__.new( s, nr[ s ] )
            end
            me.requisite_slugs.each do |s_|
              first[ s_ ] or next
              a.push Node__.new( s_, nr[ s_ ] )
            end
          else
            ::Kernel._B
          end

          Common_::Stream.via_nonsparse_array a
        end
      end

      Node__ = ::Struct.new :label, :identifier_string

      class Association___

        def initialize asc, nr

          if asc.waypoint.has_only_one_means
            @from_identifier_string = nr.general_identifier_string_via_slug asc.waypoint_slug
          else
            ::Kernel._B
          end

          @to_identifier_string = nr.general_identifier_string_via_slug asc.requisite_slug
        end

        attr_reader(
          :from_identifier_string,
          :to_identifier_string,
        )
      end

      class Name_Registry___

        def initialize
          @_gen_h = {}
        end

        def general_identifier_string_via_slug slug

          @_gen_h.fetch slug do
            s = slug.gsub BLACK_RX___, EMPTY_S_
            s.gsub! DASH_, UNDERSCORE_
            @_gen_h[ slug ] = s
            s
          end
        end

        alias_method :[], :general_identifier_string_via_slug

        BLACK_RX___ = /[^-a-z]+/
        DASH_ = '-'
        EMPTY_P_ = -> { NOTHING_ }
        EMPTY_S_ = ''
        UNDERSCORE_ = '_'
      end
    end
  end
end
