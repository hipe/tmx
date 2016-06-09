class Skylab::Task

  module MagneticsViz

    class Models_::Graph

      class << self

        def begin
          new
        end

        private :new
      end  # >>

      def initialize
        @_waypoints_box = Common_::Box.new
        @_waypoints_box_controller = @_waypoints_box.algorithms
      end

      # --

      def add_means slug_Bs, slug_A

        @_waypoints_box_controller.if_has_name( slug_A,

          -> wp do
            wp.add_means Means__.new( wp.length, slug_Bs, slug_A )
          end,
          -> bx, k do
            bx.add k, Waypoint___.new( Means__.new( 0, slug_Bs, slug_A ) )
          end,
        )
        NIL_
      end

      def finish
        @_waypoints_box.each_value do |wp|
          wp.finish_waypoint
        end
        self
      end

      # --

      def to_waypoint_stream
        @_waypoints_box.to_value_stream
      end

      # ==

      class Waypoint___

        def initialize first_means
          @_meanss = [ first_means ]
        end

        # --

        def add_means me
          @_meanss.push me ; nil
        end

        def finish_waypoint
          @_d_kn = Common_::Known_Known[ @_meanss.length ]
          @_meanss.freeze ; nil
        end

        # --

        def to_association_stream

          to_means_stream.expand_by do |me|

            me.to_association_stream.map_by do |asc|

              Qualified_Association___.new(
                asc.requisite_slug, asc.waypoint_slug, me )
            end
          end
        end

        def to_means_stream
          Common_::Stream.via_nonsparse_array @_meanss
        end

        def _
          @_meanss.fetch 0
        end
        alias_method :only_means, :_
        alias_method :first_means, :_
        remove_method :_

        def has_only_one_means
          1 == @_d_kn.value_x
        end

        def length
          @_meanss.length
        end

        def meanss
          @_meanss
        end
      end

      class Qualified_Association___

        def initialize s, s_, o
          @requisite_slug = s
          @waypoint_slug = s_
          @_means = o
        end

        def means_identifier_integer
          @_means.means_identifier_integer
        end

        attr_reader(
          :requisite_slug,
          :waypoint_slug,
        )
      end

      class Means__

        def initialize d, slug_Bs, slug_A

          @means_identifier_integer = d
          @requisite_slugs = slug_Bs
          @waypoint_slug = slug_A
        end

        def to_association_stream

          Common_::Stream.via_nonsparse_array( @requisite_slugs ).map_by do |s|
            Raw_Association___.new @waypoint_slug, s
          end
        end

        attr_reader(
          :means_identifier_integer,
          :requisite_slugs,
          :waypoint_slug,
        )
      end

      Raw_Association___ = ::Struct.new :waypoint_slug, :requisite_slug
    end
  end
end
