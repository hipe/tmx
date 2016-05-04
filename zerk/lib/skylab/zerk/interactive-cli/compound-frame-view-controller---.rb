module Skylab::Zerk

  class InteractiveCLI

    module Compound_Frame_ViewController___  # see [#038]

      # mainly, the 2-column table. of this, mainly "item liner"

      # <-

    class << self

      def default_instance
        Placeholder_instance___
      end

      def common_instance
        Common_Instance___
      end
    end  # >>

    Placeholder_instance___ = -> _ do

      mvc = _.main_view_controller
      produce_top_frame = _.method :top_frame

      -> y do
        y << "«compound placeholder»"
        _bf = produce_top_frame.call.button_frame
        mvc.express_buttonesques _bf
        y
      end
    end

    class Common_Instance___

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize _
        @main_view_controller = _.main_view_controller
        @expression_agent = _.expression_agent
        @item_liner = Item_Liner___.new
        @produce_top_frame = _.method :top_frame
        freeze
      end

      def call y  # imagine `express_compound_frame_into__`

        _boundary  # after the prompt and what was entered

        @main_view_controller.express_location_area

        Express_as_table___.new( y, self ).execute

        _boundary

        _button_frame = @produce_top_frame.call.button_frame

        # (hypothetically there could be no buttons, and hypoth'ly s'OK)

        @main_view_controller.express_buttonesques _button_frame
        y
      end

      def _boundary
        @main_view_controller.touch_boundary ; nil
      end

      # --

      def top_frame
        @produce_top_frame.call
      end

      attr_reader(
        :expression_agent,
        :item_liner,
        :stack,
      )
    end

    class Express_as_table___

      # render a two-column table with names and "item text"  #[#br-096]

      def initialize y, _

        @expression_agent = _.expression_agent
        @item_liner = _.item_liner
        @top_frame = _.top_frame
        @y = y
      end

      def execute
        __populate_columns
        ___express_columns
        @y
      end

      def ___express_columns

        col_A = @_col_A ; col_B = @_col_B

        format = Formats___.new @_max

        st = Callback_::Stream.via_times col_A.length
        begin

          d = st.gets
          d or break

          lines = col_B.fetch d

          if lines.length.zero?
            # when there is no column B content for this item, skip the
            # above formating entirely (so there's no trailing whitespace)
            # but make the leading whitespace the same as there (#here).

            @y << ( format.for_one_column % col_A.fetch( d ) )
            redo
          end

          @y << ( format.for_two_columns % [ col_A.fetch( d ), lines.fetch( 0 ) ] )

          if 1 < lines.length
            1.upto( lines.length - 1 ).each do | d_ |
              @y << ( format.for_second_column_only % lines.fetch( d_ ) )
            end
          end
          redo
        end while nil
        NIL_
      end

      def __populate_columns

        col_A = [] ; col_B = [] ; max = 0

        st = @top_frame.to_load_ticket_stream_for_UI

        item_liner = @item_liner.__for @top_frame, @expression_agent

        begin
          lt = st.gets
          lt or break

          lines = item_liner.__lines_for lt
          lines or redo
          col_B.push lines

          s = lt.name.as_slug
          len = s.length
          if max < len
            max = len
          end

          col_A.push s
          redo
        end while nil

        @_col_A = col_A ; @_col_B = col_B ; @_max = max ; nil
      end
    end  # end "express table

    # ->

      # ==

      class Item_Liner___

        # a "liner" is a thing that makes lines. in this case it makes
        # the *description* line(s) for *one* item in a list of items.

        def initialize
          @lines_for_atomesque = nil  # (might split)
          @lines_for_compound = nil
          @lines_for_operation = nil
        end

        def __for cframe, expag  # careful
          @compound_frame = cframe
          @expression_agent = expag
          self
        end

        def __lines_for lt
          send lt.four_category_symbol, lt
        end

      private

        def compound lt
          ( @lines_for_compound ||= Item_Lines_for_compound___ )[ lt, self ]
        end

        def operation lt
          ( @lines_for_operation ||= Here_::Operation_Item_Liner___ )[ lt, self ]
        end

        def entitesque lt
          ( @lines_for_atomesque ||= Here_::Atomesque_Item_Liner___ )[ lt, self ]
        end

        def primitivesque lt
          ( @lines_for_atomesque ||= Here_::Atomesque_Item_Liner___ )[ lt, self ]
        end

      public

        attr_reader(
          :compound_frame,
          :expression_agent,
        )
      end

      # ==

      class Formats___  # :#here

        def initialize d
          @d = d
        end

        def for_second_column_only
          @___2_ ||= "  #{ SPACE_ * @d }  %s"
        end

        def for_two_columns
          @___2 ||= "#{ for_one_column }  %s"
        end

        def for_one_column
          @___1 ||= "  %#{ @d }s"
        end
      end

      # ==

      Item_Lines_for_compound___ = -> * do
        NOTHING_  # as explained in #"decision D"
      end

      # ==

      This_ = self
    end
  end
end
