module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      Models_ = ::Module.new

      class Models_::Table

        class << self

          def new_via_bundle_and_repository bundle, repository

            Build___.new( bundle, repository ).execute
          end
        end  # >>

        def initialize rows, x
          @glyph_mapper = x
          @rows = rows
        end

        attr_reader :glyph_mapper, :rows

        class Build___

          def initialize bundle, repository

            @matrix = bundle.build_matrix_via_repository repository
            order_box = @matrix.order_box
            @number_of_columns = order_box.length
            @order_box_length = order_box.length
            @order_box_h = order_box.h_

            gm = Build_glyph_mapper___.new( bundle.statistics,
              # "\u2058",  # Four Dot Punctuation - ⁘
              "\u29bf",  # Circled Bullet - ⦿
              # "\u25c9",  # Fisheye - ◉
              "\u25cf",  # Blank Circle - ●
              "\u2022",  # Bullet - ●
              "\u2b24"   # Blank Large Circle - ⬤
            ).execute


            @__gm = gm

            @B_tree = gm.B_tree
          end

          def execute

            _row_a = @matrix.bundle.trails.map do | trail |
              Row___.new( __row_via_trail( trail ), trail.path )
            end

            Table_.new _row_a, @__gm
          end

          Row___ = ::Struct.new :a, :to_tree_path

          def __row_via_trail trail

            row = ::Array.new @order_box_length

            st = Callback_::Stream.via_nonsparse_array trail.filechanges

            bf = st.gets

            cel = _cel_via_bundle_filechange bf

            cel.is_first = true

            row[ @order_box_h.fetch bf.SHA.string ] = cel

            begin

              bf = st.gets
              bf or break
              row[  @order_box_h.fetch bf.SHA.string ] =
                _cel_via_bundle_filechange( bf )

              redo
            end while nil

            row
          end

          def _cel_via_bundle_filechange bundle_filechange

            _cc_d = bundle_filechange.fc.change_count

            _cat_d = @B_tree.category_for _cc_d

            _cat_d or self._SANITY

            Modality_Filechange___.new false, _cat_d, bundle_filechange
          end
        end

        Modality_Filechange___ = ::Struct.new :is_first, :amount_classification, :bundle_filechange

        class Build_glyph_mapper___  # algorithm in [#026]

          def initialize statistics, create_glyph, * glyphs

            @__create_glyph = create_glyph
            @__glyphs = glyphs

            @number_of_categories = glyphs.length
            @stats = statistics
          end

          def execute

            __init_B_tree

            Glyph_Mapper___.new do | o |
              o.B_tree = @B_tree
              o.create_glyph = @__create_glyph
              o.glyphs = @__glyphs
            end
          end

          def __init_B_tree

            __init_category_list

            @B_tree = GitViz_.lib_.basic::Tree::Binary.
              via_sorted_range_list @category_list

            NIL_
          end

          def __init_category_list

            @first = @stats.first
            @last = @stats.last

            if @last == @first

              self._WHEN_EXPANSE_OF_ONE
            else

              @expanse = @last - @first + 1
              @units_per_category = 1.0 * @expanse / @number_of_categories

              if 1.0 > @units_per_category

                __init_category_list_simply
              else

                __init_category_list_normally
              end
            end
            NIL_
          end

          def __init_category_list_simply

            # you have more categories than you have expanse. chop off the
            # latter catergories because meh. procede as if etc b.c meh

            @category_list = @expanse.times.map do | d |
              x = @first + d
              Category__.new x, x, d
            end
            NIL_
          end

          def __init_category_list_normally

            a = []
            begin_d = @first
            st = Callback_::Stream.via_range( 1 .. @number_of_categories )
            start_d = @first

            begin

              d = st.gets
              d or break

              begin_d_ = start_d + ( d * @units_per_category ).to_i

              a.push Category__.new( begin_d, begin_d_ - 1, d - 1 )

              begin_d = begin_d_

              redo
            end while nil

            @category_list = a
            NIL_
          end
        end

        class Category__

          def initialize begin_, end_, d
            @begin = begin_
            @category_d = d
            @end = end_
          end

          attr_reader :begin, :category_d, :end

          def category_for d

            if @begin <= d && @end >= d
              @category_d
            end
          end
        end

        class Glyph_Mapper___

          def initialize
            yield self
            freeze
          end

          attr_accessor :B_tree, :create_glyph, :glyphs
        end

        Table_ = self
      end
    end
  end
end
