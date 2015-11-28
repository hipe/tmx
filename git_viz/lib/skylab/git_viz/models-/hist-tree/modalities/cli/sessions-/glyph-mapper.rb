module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      Sessions_ = ::Module.new

      class Sessions_::Glyph_Mapper  # algorithm in [#026]

        class << self

          def start create_glyph, * glyphs

            new glyphs, create_glyph
          end
        end  # >>

        def initialize glyphs, create_glyph

          @create_glyph = create_glyph
          @glyphs = glyphs
        end

        attr_reader :create_glyph, :glyphs

        def bake_for statistics
          Bake___.new( statistics, @glyphs, @create_glyph ).execute
        end

        class Baked___ < self

          def initialize _B_tree, x, x_
            super( x, x_ )
            @B_tree = _B_tree
          end

          attr_reader :B_tree

        end

        class Bake___

          def initialize * a

            @stats, @glyphs, @create_glyph = a

            @number_of_categories = @glyphs.length
          end

          def execute

            __init_category_list

            _B_tree = Home_.lib_.basic::Tree::Binary.
              via_sorted_range_list @category_list

            Baked___.new( _B_tree, @glyphs, @create_glyph )
          end

          def __init_category_list

            @first = @stats.first
            @last = @stats.last

            @expanse = @last - @first + 1  # last == first OK

            @units_per_category = Rational @expanse, @number_of_categories

            if 1.0 > @units_per_category

              __init_category_list_simply
            else

              __init_category_list_normally
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
      end
    end
  end
end
