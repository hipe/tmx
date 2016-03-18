module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      Actors_ = ::Module.new

      class Actors_::Scale_time  # algorithm in [#029]

        Attributes_actor_.call( self,
          :column_B_rows,
          :column_A_max_width,
          :column_A,
          :width,
          :glyph_mapper,
          :text_downstream,
        )

        def execute

          ok = __resolve_available_width
          ok &&= __resolve_first_and_last_datetime
          ok &&= __resolve_best_fit_scale_adapter
          ok && __via_scale_adapter
        end

        def __resolve_available_width

          @available_width = @width - @column_A_max_width - A_B_SEPARATOR_WIDTH_
          if 1 > @available_width
            @available_width = 1
          end
          ACHIEVED_
        end

        A_B_SEPARATOR_ = ' |'
        A_B_SEPARATOR_WIDTH_ = A_B_SEPARATOR_.length

        def __resolve_first_and_last_datetime

          # this is inelegant. if we really wanted to we could etc

          first_ci = nil
          last_ci = nil

          @column_B_rows.each do | row |
            row or next

            if ! first_ci
              mfc = row.to_a.first
              if mfc
                first_ci = mfc.ci
                last_ci and break
              end
            end

            if ! last_ci
              mfc = row.to_a.last
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

        def __resolve_best_fit_scale_adapter

          if @first_datetime.object_id == @last_datetime.object_id

            self.__RESOLVE_best_fit_scale_adapter_when_one_column

          else

            __resolve_best_fit_scale_adapter_when_multiple_columns
          end
        end

        def __resolve_best_fit_scale_adapter_when_multiple_columns

          rfq = Request_For_Quote___.new(
            @available_width,
            @last_datetime - @first_datetime,
            @first_datetime, @last_datetime )

          cls = Scale_Adapters_::Hourly  # put whatever has the smallest buckets here

          begin

            bid = cls.bid rfq
            if bid
              break
            end

            cls = Scale_Adapters_.const_get cls.next, false
            redo

          end while nil

          bid and begin
            @scale_adapter = bid
            ACHIEVED_
          end
        end

        Request_For_Quote___ = ::Struct.new(
          :width, :distance_in_days_rational, :first_datetime, :last_datetime )

        def __via_scale_adapter

          o = @scale_adapter
          o.column_B_rows = @column_B_rows
          o.column_A_max_width = @column_A_max_width
          o.column_A = @column_A
          o.glyph_mapper = @glyph_mapper
          o.text_downstream = @text_downstream

          o.render
        end

        module Time_Unit_Adapters
          class << self
            def [] sym
              @h.fetch sym do
                @h[ sym ] = const_get(
                  Callback_::Name.via_variegated_symbol( sym ).as_const,
                  false )
              end
            end
          end  # >>
          @h = {}
          Autoloader_[ self ]
        end

        module Common_Time_Unit_Adapter_Module_Methods_

          # etc

        end

        Autoloader_[ Scale_Adapters_ = ::Module.new ]
        FOUR_ = 4
        Scale_time_ = self
      end
    end
  end
end
