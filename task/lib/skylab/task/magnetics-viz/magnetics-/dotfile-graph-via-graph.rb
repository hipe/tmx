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

      def express_into_under y, _expag
        dup.__etc y
      end

      def __etc y
        @y = y
        y << "digraph g {\n"
        __express_associations
        y << "\n"
        __express_nodes
        y << "}\n"
      end

      def __express_associations
        st = to_association_stream
        begin
          o = st.gets
          o or break
          @y << "  #{ o.from_identifier_string } -> #{ o.to_identifier_string }\n"
          redo
        end while nil
      end

      def __express_nodes
        st = to_node_stream
        begin
          o = st.gets
          o or break
          @y << "  #{ o.identifier_string } [label=\"#{ o.label }\"]\n"
          redo
        end while nil
      end

      def to_association_stream

        nr = @_name_registry

        @graph.to_waypoint_stream.expand_by do |wp|

          st = wp.to_association_stream.map_by do |asc|
            Association__.__normal_via asc, wp, nr
          end

          if wp.has_only_one_means
            st
          else
            a = []
            wp.meanss.each do |me|
              a.push Association__.waypointy_via__( me, wp, nr )
            end
            x = nil
            a.push x while x = st.gets
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
            s_a = me.requisite_slugs
            if s_a
              s_a.each do |s_|
                first[ s_ ] or next
                a.push Node__.new( s_, nr[ s_ ] )
              end
            end
          else
            # of each means group (i.e waypoint), you want:
            #   • a node for the abstract waypoint IFF not done yet
            #   • certainly a node for each means "head"
            #   • a node for each means requisite IFF not done yet

            s = wp.first_means.waypoint_slug
            if first[ s ]
              a.push Node__.new( s, nr[ s ] )
            end
            wp.meanss.each do |me_|
              a.push Node__.new(
                "(#{ me_.means_identifier_integer.to_s })",
                nr._specific_IS_via( me_ ),
              )
              s_a = me_.requisite_slugs
              if s_a
                s_a.each do |s_|
                  first[ s_ ] or next
                  a.push Node__.new( s_, nr[ s_ ] )
                end
              end
            end
          end

          Common_::Stream.via_nonsparse_array a
        end
      end

      Node__ = ::Struct.new :label, :identifier_string

      class Association__

        class << self

          def __normal_via asc, wp, nr
            new.__init_normal asc, wp, nr
          end

          def waypointy_via__ me, wp, nr
            new.__init_waypointy me, wp, nr
          end

          private :new
        end  # >>

        def __init_waypointy me, wp, nr

          @from_identifier_string = nr[ me.waypoint_slug ]

          @to_identifier_string = nr._specific_IS_via me

          self
        end

        def __init_normal asc, wp, nr

          if wp.has_only_one_means
            @from_identifier_string = nr[ asc.waypoint_slug ]
          else
            @from_identifier_string = nr._specific_IS_via asc
          end

          @to_identifier_string = nr[ asc.requisite_slug ]

          self
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

        def _specific_IS_via me

          _s = general_identifier_string_via_slug me.waypoint_slug

          "#{ _s }_#{ me.means_identifier_integer }"
        end

        def general_identifier_string_via_slug slug

          @_gen_h.fetch slug do
            s = slug.gsub BLACK_RX___, EMPTY_S_
            s.gsub! DASH_, UNDERSCORE_

            if IS_KEYWORD___[ s ]
              s.concat "_not_keyword"
            end

            @_gen_h[ slug ] = s
            s
          end
        end

        alias_method :[], :general_identifier_string_via_slug

        IS_KEYWORD___ = { "digraph" => true }  # ..

        BLACK_RX___ = /[^-a-z]+/
        DASH_ = '-'
        EMPTY_P_ = -> { NOTHING_ }
        EMPTY_S_ = ''
        UNDERSCORE_ = '_'
      end
    end
  end
end
