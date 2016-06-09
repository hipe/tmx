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

        me = Means___.new slug_Bs, slug_A

        @_waypoints_box_controller.if_has_name( me.waypoint_slug,

          -> wp do
            wp.add_means me
          end,
          -> bx, k do
            bx.add k, Waypoint___.new( bx.length, me )
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

        def initialize d, first_means
          @_meanss = [ first_means ]
          @waypoint_identifier_integer = d
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
                asc.requisite_slug, self, asc.waypoint_slug )
            end
          end
        end

        def to_means_stream
          Common_::Stream.via_nonsparse_array @_meanss
        end

        def only_means
          @_meanss.fetch 0
        end

        def has_only_one_means
          1 == @_d_kn.value_x
        end

        attr_reader(
          :waypoint_identifier_integer,
        )
      end

      Qualified_Association___ = ::Struct.new(
        :requisite_slug, :waypoint, :waypoint_slug )

      class Means___

        def initialize slug_Bs, slug_A

          @requisite_slugs = slug_Bs
          @waypoint_slug = slug_A
        end

        def to_association_stream

          Common_::Stream.via_nonsparse_array( @requisite_slugs ).map_by do |s|
            Raw_Association___.new @waypoint_slug, s
          end
        end

        attr_reader(
          :requisite_slugs,
          :waypoint_slug,
        )
      end

      Raw_Association___ = ::Struct.new :waypoint_slug, :requisite_slug
    end
  end
end
