module Skylab::Face

  class CLI::Table

    class Fill_

      def self.produce_late_pass_renderers a
        shell = new
        shell.cel_renderer_a = a
        yield shell
        shell.execute
      end

      def initialize
      end

      attr_accessor :cel_renderer_a, :field_fetcher,
        :field_stats, :left, :sep, :right, :num_fields,
        :target_width_d

      def execute
        calc_width_taken_and_parts_total
        @fill_d_a && calc_and_distribute_remaining_width
        rslv_renderers ; nil
      end
    private
      def rslv_renderers
        @render_d_a.each do |d|
          field = @field_fetcher[ d ]
          @cel_renderer_a[ d ] = field.cel_renderer_p_p[
            Column__.new( d, @width_h.fetch( d ),
              @field_stats.fetch( d ), field ) ]
        end ; nil
      end

      class Column__
        def initialize d, width, stats, field
          @d = d ; @width = width ; @stats = stats ; @field = field
        end
        attr_reader :d, :width, :stats, :field
      end

      def calc_width_taken_and_parts_total
        @fill_d_a = nil ; @width_h = {}
        @width_taken_by_data = 0
        @parts_total = 0.0 ; @render_d_a = []
        @num_fields.times do |d|
          field = @field_fetcher[ d ]
          fill = field.fill
          if fill
            @render_d_a.push d
            ( @fill_d_a ||= [] ).push d
            @parts_total += fill.some_parts_x
          else
            width = @field_stats.fetch( d ).max_strlen
            if field.cel_renderer_p_p
              @render_d_a.push d
              @width_h[ d ] = width
            end
            @width_taken_by_data += width
          end
        end
      end

      def calc_and_distribute_remaining_width
        available_width = avail_width
        used_width = 0
        @fill_d_a.each do |d|
          field = @field_fetcher[ d ]
          width_f = field.fill.some_parts_x / @parts_total * available_width
          width_d = width_f.floor
          @width_h[ d ] = width_d
          used_width += width_d
        end
        overage = available_width - used_width  # see #overage-here
        if 0 < overage
          last = @fill_d_a.length - 1
          overage.times do |d|
            @width_h[ @fill_d_a[ last - d ] ] += 1
          end
        end ; nil
      end

      def avail_width
        @target_width_d or raise "implement me - ncurses"
        x = @target_width_d
        x -= @width_taken_by_data
        @right and x -= @right.length
        @left and x -= @left.length
        if @sep
          x -= ( @num_fields - 1 ) * @sep.length
        end
        0 < x ? x : 0
      end

      class Shell
        def initialize
          @previous_fill = nil
        end
        attr_writer :previous_fill
        attr_reader :d, :fill
        def from_d_parse_iambic_passively d, x_a
          @d = d ; @x_a = x_a
          if @previous_fill
            @previous_fill.dupe do |fill|
              @fill = fill ; absrb
            end
          else
            Fill__.new do |fill|
              @fill = fill ; absrb
            end
          end ; nil
        end
      Face_::Lib_::Fields_from_methods[ :niladic, :passive, :absorber, :absrb,
          -> do
        def parts
          @fill.parts_x = iambic_property
        end
        def with
          @fill.with_x = iambic_property
        end
      end ]
      end

      class Fill__
        def initialize
          @parts_x = nil
          yield self
          freeze
        end
        def dupe
          yield( otr = dup )
          otr.freeze
        end
        attr_accessor :parts_x, :with_x
        def some_parts_x
          @parts_x || 1.0
        end
      end

      # ~ builtins

      def self.p_p_from_i i
        Autoloader_.const_reduce( [ i ], Builtins__ ).p_p
      end

      module Builtins__
        Autoloader_[ self, :boxxy ]
      end
    end
  end
end
