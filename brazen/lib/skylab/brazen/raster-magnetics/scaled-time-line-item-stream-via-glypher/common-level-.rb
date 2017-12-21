module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class CommonLevel_  # algorithm in [#080]

      class << self

        def bid rfq  # request for quote

          # you MUST read [#080.G] or you WILL NOT understand this!

          _tua = time_unit_adapter_
          block_begin_dt = _tua.nearest_previous_block_begin_datetime_ rfq.first_datetime

          _margin_days_rational = rfq.first_datetime - block_begin_dt
            # the extra 'head margin' of time we have to pay for

          _block_days_rational = _margin_days_rational + rfq.distance_in_days_rational
            # the span of time we have to pay for (not including a tail margin)

          _block_count_rational = _block_days_rational / self::DAYS_PER_BLOCK
            # the number of blocks we have to pay for (as rational)

          block_count = _block_count_rational.ceil
            # round it up to get the real number of blocks we need

          # NOW, how does the number of blocks we would need compare to the
          # number of screen tiles we have at our disposal? whether or not
          # we fit determines whether or not the current level is appropriate.

          if rfq.width >= block_count
            new block_begin_dt, block_count
          end
        end

        def time_unit_adapter_
          Here_::Units_[ self::INTERNAL_UNIT ]
        end
      end  # >>

          def initialize block_begin_dt, block_count

            @block_count = block_count
            @days_per_block = self.class::DAYS_PER_BLOCK
            @first_block_begin_datetime = block_begin_dt
            @time_unit_adapter = self.class.time_unit_adapter_
            @zone_for_comparison = block_begin_dt.zone

          @__mutex = nil  # see
          end

        def RENDER_OR_TO_STREAM_(
          text_downstream: nil,
          viz_column_rows: nil,
          business_column_max_width: nil,
          business_column_rows: nil,
          glypherer: nil,
          column_order: nil
        )

          remove_instance_variable :@__mutex  # if this fails, dup and mutate

          @normal_column_order = ColumnOrder___.new column_order

          @text_downstream = text_downstream
          @viz_column_rows = viz_column_rows
          @business_column_max_width = business_column_max_width
          @business_column_rows = business_column_rows
          @glypherer = glypherer

          __init_row_block_boxes  # (B)
          __bake_glyph_mapper  # (C)
          __flush  # (D)
        end

        # -- D.

        def __flush

          # hackishly protofit this to work for stream idiom from expression idiom

          if @text_downstream
            __express_for_flush
          else
            __express_for_money_cray
          end
        end

        def __express_for_flush

          io = remove_instance_variable :@text_downstream

          _express_headers_into io

          st = _flush_slats_stream
          begin
            o = st.gets
            o || break
            s = o.to_mutable_string
            s << NEWLINE_
            io << s
            redo
          end while above
          ACHIEVED_  # oldschool [br] compat
        end

        def __express_for_money_cray

          # for modalities other than CLI we wouldn't want to do the
          # headers like so, but sheah right

          _s_a = _express_headers_into( [] ).freeze

          _st = _flush_slats_stream

          HeaderLinesAndSlatsRowStream___.new(
            _s_a,
            _st,
          )
        end

        def _express_headers_into io

          if @normal_column_order.do_express_business_column_first
            _use_business_column_max_width = @business_column_max_width
          end

          Here_::SubMagnetics_::ExpressHeaders_via_Arguments.call_by(
            text_downstream: io,
            hook_outs: self,
            row_block_boxes: @row_block_boxes,
            first_block_begin_datetime: @first_block_begin_datetime,
            days_per_block: @days_per_block,
            block_count: @block_count,
            time_unit_adapter: @time_unit_adapter,
            business_column_max_width: _use_business_column_max_width,
          )
        end

        def _flush_slats_stream

          slats_rowser = Here_::SubMagnetics_::SlatsRowser_via_Level.new(
            business_column_max_width: @business_column_max_width,
            block_count: @block_count,
            row_block_boxes: @row_block_boxes,
            normal_column_order: @normal_column_order,
            glypher: @glypher,
          )

          scn = Scanner_[ @business_column_rows ]
          row_offset = -1

          Common_.stream do
            unless scn.no_unparsed_exists
              row_offset += 1
              _s = scn.gets_one
              slats_rowser.slats_row_via _s, row_offset
            end
          end
        end

          def within sumzn

            if sumzn.subject.has_content

              within_when_content_ sumzn

            else

              within_when_no_content_ sumzn
            end

            NIL_
          end

          def within_when_no_content_ sumzn

            if sumzn.prev.normal_datetime.year == sumzn.subject.normal_datetime.year

              sumzn.downstream << nil

            else

              Levels_::Annual.within_ sumzn
            end
            NIL_
          end

          def within_when_content_ sumzn

            dt = sumzn.subject.normal_datetime
            d = @time_unit_adapter.particular_offset_within_annual_cycle_of_datetime_ dt

            if d

              if d.zero?

                # whenever this is the first block in an annual cycle always
                # display this new year instaad of any particular unit amount

                Levels_::Annual.within_ sumzn

              else

                send :"within__#{  sumzn.width }__", sumzn
              end
            else
              self._FUN_2
            end
            NIL_
          end

          STATE_DRIVEN_WITHIN_ = -> sumzn do
            @p[ sumzn ]
          end

          def initial_state_ sumzn
            @p = method :__mday
            Levels_::Monthly.within_ sumzn
          end

          def __mday sumzn
            @p = method :significant_change_or_etc_
            Levels_::Daily.mday_within_ sumzn
          end

          def significant_change_or_etc_ sumzn

            sym = _find_unit_of_significant_change sumzn
            if sym
              _process_unit_of_significan_change sym, sumzn

            elsif sumzn.subject.has_content

              particular_ sumzn
            else

              sumzn.downstream << nil
              NIL_
            end
          end

          def _find_unit_of_significant_change sumzn

            dt_ = sumzn.prev.normal_datetime
            dt = sumzn.subject.normal_datetime

            UNITS___.detect do | sym_ |
              dt_.send( sym_ ) != dt.send( sym_ )
            end
          end

          UNITS___ = %w( year month day )

          def _process_unit_of_significan_change sym, sumzn

            send :"__#{ sym }__within", sumzn
            NIL_
          end

          def __year__within sumzn

            Levels_::Annual.within_ sumzn
          end

          def __month__within sumzn

            Levels_::Monthly.within_ sumzn
          end

          def __day__within sumzn

            if sumzn.subject.normal_datetime.wday.zero?

              Levels_::Daily.mday_within_ sumzn
            else

              Levels_::Daily.day_of_week_within_ sumzn
            end
          end

        # -- C. bake glyph mapper

        def __bake_glyph_mapper

          stats = []
          @row_block_boxes.each do |bx|
            bx || next
            bx.each_value do |viz_tile|
              stats.push viz_tile.visual_weight_count
            end
          end
          stats.sort!.freeze
          @glypher = @glypherer.glypher_via_statistics stats
          NIL
        end

        # -- B. row block boxes

        def __init_row_block_boxes

          boxes = ::Array.new @viz_column_rows.length

          @viz_column_rows.each_with_index do |row_o, row_d|

            row_o || next

            block_box = Common_::Box.new

            row_o.each_business_item_for_rasterized_visualization do |bi|

              bi || next

              _block_offset = __block_offset_via_datetime bi.date_time_for_rasterized_visualization

              _ac = block_box.touch _block_offset do
                VisualizationTile___.begin
              end

              _ac.__see_business_item_ bi
            end

            boxes[ row_d ] = block_box
          end

          @row_block_boxes = boxes ; nil
        end

        def __block_offset_via_datetime dt

          if @zone_for_comparison != dt.zone
            dt = dt.new_offset @zone_for_comparison
          end

          _days_distance_rational = dt - @first_block_begin_datetime

          _number_of_blocks_rational = _days_distance_rational / @days_per_block

          _number_of_blocks_rational.floor
        end

        # -- A. support
      # -

      # ==

      class ColumnOrder___

        # normalize an incoming specification of column order - represeent
        # it in exactly the way we want to know about it internally

        def initialize sym_a
          sym_a || fail
          2 == sym_a.length || fail
          if :biz_column == sym_a.first
            if :viz_column == sym_a.last
              @do_express_business_column_first = true
            else
              fail
            end
          elsif :viz_column == sym_a.first
            if :biz_column == sym_a.last
              @do_express_business_column_first = false
            else
              fail
            end
          else
            fail
          end
          freeze
        end

        attr_reader(
          :do_express_business_column_first,
        )
      end

      # ==

      class VisualizationTile___

        class << self
          alias_method :begin, :new
          undef_method :new
        end  # >>

        def initialize
          @visual_weight_count = 0
        end

        def __see_business_item_ bi
          @visual_weight_count += bi.count_towards_weight_for_rasterized_visualization
          NIL
        end

        attr_reader(
          :visual_weight_count,
        )
      end

      # ==

      HeaderLinesAndSlatsRowStream___ = ::Struct.new(
        :header_lines,
        :slats_row_stream,
      )

      # ==
      # ==
    end
  end
end
# #history-A.1: mostly rewritten to work for visual blame
