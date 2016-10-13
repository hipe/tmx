module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        class Common_Scale_Adapter_  # algorithm in [#029]

          class << self

            def bid rfq

              bucket_begin_dt = _time_unit_adapter_.
                nearest_previous_bucket_begin_datetime_(
                  rfq.first_datetime )

              _offset_rational = rfq.first_datetime - bucket_begin_dt

              bucket_count = (
                ( _offset_rational + rfq.distance_in_days_rational ) /
                self::DAYS_PER_BUCKET
              ).ceil

              if rfq.width >= bucket_count
                new bucket_begin_dt, bucket_count
              end
            end

            def _time_unit_adapter_
              Scale_time_::Time_Unit_Adapters[ self::INTERNAL_UNIT ]
            end

          end  # >>

          def initialize bucket_begin_dt, bucket_count

            @bucket_count = bucket_count
            @days_per_bucket = self.class::DAYS_PER_BUCKET
            @first_bucket_begin_datetime = bucket_begin_dt
            @tua = self.class._time_unit_adapter_
            @zone_for_comparison = bucket_begin_dt.zone
          end

          attr_writer :column_B_rows, :column_A_max_width, :column_A,
            :glyph_mapper, :text_downstream

          def render

            __resolve_row_bucket_boxes
            __resolve_baked_glyph_mapper
            __post_render
          end

          # ~

          def __resolve_row_bucket_boxes

            a_ = ::Array.new @column_B_rows.length

            @column_B_rows.each_with_index do | row_o, row_d |
              row_o or next

              bucket_box = Common_::Box.new

              row_o.to_a.each do | filechange |
                filechange or next

                _bucket_index = _determine_bucket_index_for_datetime(
                  filechange.author_datetime )

                bucket_box.touch _bucket_index do

                  Aggregated_Cel___.new

                end.see_filechange filechange
              end

              a_[ row_d ] = bucket_box

            end

            @row_bucket_boxes = a_

            NIL_
          end

          def _determine_bucket_index_for_datetime dt

            if @zone_for_comparison != dt.zone
              dt = dt.new_offset @zone_for_comparison
            end

            _days_distance_rational = dt - @first_bucket_begin_datetime

            _number_of_buckets_rational =
              _days_distance_rational / @days_per_bucket

            _number_of_buckets_rational.floor
          end

          class Aggregated_Cel___
            def initialize
              @constituent_count = 0
              @sum = 0
            end
            attr_reader :constituent_count, :sum
            def see_filechange fc
              @constituent_count += 1
              @sum += fc.change_count
              NIL_
            end
          end

          def __resolve_baked_glyph_mapper

            stats = []
            @row_bucket_boxes.each do | box |
              box or next
              box.each_value do | agd_cel |
                stats.push agd_cel.sum
              end
            end
            stats.sort!.freeze
            @baked_glyph_mapper = @glyph_mapper.bake_for stats
            NIL_
          end

          # ~

          def __post_render

            __render_headers
            __render_data_rows
          end

          def __render_headers

            Scale_time_::Actors_::Render_headers.new(
              @text_downstream,
              @row_bucket_boxes,
              @first_bucket_begin_datetime,
              @bucket_count,
              @column_A_max_width,
              @days_per_bucket,
              @tua,
              self ).execute
            NIL_
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

              Scale_Adapters_::Annual.within_ sumzn
            end
            NIL_
          end

          def within_when_content_ sumzn

            dt = sumzn.subject.normal_datetime
            d = @tua.particular_offset_within_annual_cycle_of_datetime_ dt

            if d

              if d.zero?

                # whenever this is the first bucket in an annual cycle always
                # display this new year instaad of any particular unit amount

                Scale_Adapters_::Annual.within_ sumzn

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
            Scale_Adapters_::Monthly.within_ sumzn
          end

          def __mday sumzn
            @p = method :significant_change_or_etc_
            Scale_Adapters_::Daily.mday_within_ sumzn
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

            Scale_Adapters_::Annual.within_ sumzn
          end

          def __month__within sumzn

            Scale_Adapters_::Monthly.within_ sumzn
          end

          def __day__within sumzn

            if sumzn.subject.normal_datetime.wday.zero?

              Scale_Adapters_::Daily.mday_within_ sumzn
            else

              Scale_Adapters_::Daily.day_of_week_within_ sumzn
            end
          end

          def __render_data_rows

            b_tree = @baked_glyph_mapper.B_tree
            box_a = @row_bucket_boxes
            bucket_count = @bucket_count
            fmt = "%-#{ @column_A_max_width }s#{ A_B_SEPARATOR_ }"
            io = @text_downstream
            s_a = @glyph_mapper.glyphs

            @column_A.each_with_index do | s, d |

              io << fmt % s

              bx = box_a[ d ]
              if bx
                h = bx.h_

                bucket_count.times do | d_ |

                  ag_cel = h[ d_ ]
                  if ag_cel
                    io << s_a.fetch( b_tree.category_for ag_cel.sum )
                  else
                    io << SPACE_
                  end
                end
              end
              io << NEWLINE_
            end
            ACHIEVED_
          end
        end
      end
    end
  end
end
