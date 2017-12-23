# frozen_string_literal: true

module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher  # algorithm in [#080]

    class << self
      def call_by ** hh
        new( ** hh ).execute
      end
      private :new
    end  # >>

    # -
      def initialize(

        text_downstream: nil,

        semimixed_item_stream: nil,
        viz_column_rows: nil,

        business_column_max_width: nil,
        business_column_strings: nil,

        width: nil,
        glyph: nil,
        glypherer: nil,
        column_order: nil
      )
        __negotiate_viz_column_rows semimixed_item_stream, viz_column_rows

        __negotiate_glypherer glyph, glypherer

        @text_downstream = text_downstream

        @business_column_max_width = business_column_max_width
        @business_column_strings = business_column_strings

        @width = width
        @column_order = column_order
      end

      def __negotiate_viz_column_rows semimixed_item_stream, viz_column_rows

        if semimixed_item_stream
          viz_column_rows && fail  # can't have both
          @viz_column_rows = NOTHING_
          @_resolve_first_and_last_datetime = :__resolve_first_and_last_datetime_the_new_way
          @semimixed_item_stream = semimixed_item_stream
        else
          @viz_column_rows = viz_column_rows
          @_resolve_first_and_last_datetime = :__resolve_first_and_last_datetime_the_old_way
        end
      end

      def __negotiate_glypherer glyph, glypherer
        if glyph
          glypherer && fail  # we won't decide for you which one should trump which
          glypherer = Home_::RasterMagnetics::
              Glypher_via_Glyphs_and_Stats::SimpleGlypherer.new glyph
        elsif ! glypherer
          self._COVER_ME__glypherer_is_required_is_it_not__
        end
        @glypherer = glypherer ; nil
      end

      # -

        def execute
          ok = __resolve_available_width
          ok &&= __resolve_first_and_last_datetime
          ok &&= __resolve_best_fit_scale_adapter
          ok && __via_scale_adapter
        end

      # -- E. via scale adapter

      def __via_scale_adapter
        @__renderer.RENDER_OR_TO_STREAM_(
          text_downstream: @text_downstream,

          viz_column_rows: @viz_column_rows,

          business_column_max_width: @business_column_max_width,
          business_column_strings: @business_column_strings,

          glypherer: @glypherer,
          column_order: @column_order,
        )
      end

      # --

        def __resolve_available_width

          @available_width = @width - @business_column_max_width - A_B_SEPARATOR_WIDTH_
          if 1 > @available_width
            @available_width = 1
          end
          ACHIEVED_
        end

        A_B_SEPARATOR_ = ' |'
        A_B_SEPARATOR_WIDTH_ = A_B_SEPARATOR_.length

      def __resolve_first_and_last_datetime_the_old_way

          # this is inelegant. if we really wanted to we could etc

          first_ci = nil
          last_ci = nil

        @viz_column_rows.each do |row|
            row or next

            if ! first_ci
            mfc = row.business_items.first
              if mfc
                first_ci = mfc.ci
                last_ci and break
              end
            end

            if ! last_ci
            mfc = row.business_items.last
              if mfc
                last_ci = mfc.ci
                first_ci and break
              end
            end
        end

          first_ci && last_ci and begin

            @first_datetime = first_ci.author_datetime
            @last_datetime = last_ci.author_datetime
            ACHIEVED_
          end
      end

      # -- C. resolve best fit scale adapter

        def __resolve_best_fit_scale_adapter

          if @first_datetime.object_id == @last_datetime.object_id

            self.__RESOLVE_best_fit_scale_adapter_when_one_column
          else
            __resolve_best_fit_scale_adapter_when_multiple_columns
          end
        end

      def __resolve_best_fit_scale_adapter_when_multiple_columns

        rfq = RequestForQuote___.new(
          first_datetime: @first_datetime,
          last_datetime: @last_datetime,
          width: @available_width,
        )

          cls = Levels_::Hourly  # put whatever has the smallest blocks here

          begin

            bid = cls.bid rfq
            if bid
              break
            end

            cls = Levels_.const_get cls.next, false
            redo

          end while nil

        _store :@__renderer, bid
      end

      # -- B. resolve first and last datetime

      def __resolve_first_and_last_datetime
        send remove_instance_variable :@_resolve_first_and_last_datetime
      end

      def __resolve_first_and_last_datetime_the_new_way

        cache = []

        st = remove_instance_variable( :@semimixed_item_stream ).map_by do |it|
          cache.push ThisWrapper___.new it
          it.date_time_for_rasterized_visualization || self._COVER_ME__no_datetime_for_item__
        end

        dt = st.gets
        if dt
          __the_rest_of_this_money cache, dt, st
        else
          # #coverpoint1.3 - if you are given an empty stream, assume elsewhere will complain
          NOTHING_
        end
      end

      def __the_rest_of_this_money cache, dt, st

        oldest_dt = dt ; newest_dt = dt
        begin
          dt = st.gets
          dt || break
          if oldest_dt > dt
            oldest_dt = dt
          elsif newest_dt < dt
            newest_dt = dt
          end
          redo
        end while above

        @viz_column_rows && sanity
        @viz_column_rows = cache

        @first_datetime = oldest_dt
        @last_datetime = newest_dt
        ACHIEVED_
      end

      # -- A.

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==

    class RequestForQuote___

      def initialize(
        first_datetime: nil,
        last_datetime: nil,
        width: nil
      )
        @distance_in_days_rational = last_datetime - first_datetime

        @first_datetime = first_datetime
        @last_datetime = last_datetime
        @width = width
        freeze
      end

      attr_reader(
        :distance_in_days_rational,
        :first_datetime,
        :last_datetime,
        :width,
      )
    end

    # ==

    module Units_
      class << self
        def [] sym
          @_child_via_name_symbol.fetch sym do
            _c = Common_::Name.via_variegated_symbol( sym ).as_const
            x = const_get _c, false
            @_child_via_name_symbol[ sym ] = x
            x
          end
        end
      end  # >>
      @_child_via_name_symbol = {}
      Autoloader_[ self ]
    end

    # ==

    class ThisWrapper___
      def initialize x
        @x = x
      end
      def each_business_item_for_rasterized_visualization
        yield @x
        NIL
      end
    end

    # ==

        FOUR_ = 4
        Here_ = self

    # ==
    # ==
  end
end
# #history-A.1: re-housed from application to library sidesystem
