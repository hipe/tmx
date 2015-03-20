# somewhere: GitViz_.lib_.tree.from( :node_identifiers, @bunch.immutable_trail_array )

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

        def initialize rows, glyphs
          @glyphs = glyphs
          @rows = rows
        end

        attr_reader :glyphs, :rows

        class Build___

          def initialize bundle, repository

            @matrix = bundle.build_matrix_via_repository repository
            order_box = @matrix.order_box
            @number_of_columns = order_box.length
            @order_box_length = order_box.length
            @order_box_h = order_box.h_

            glyphs = Glyphs___.new bundle.statistics,
              # "\u2058",  # Four Dot Punctuation - ⁘
              "\u29bf",  # Circled Bullet - ⦿
              # "\u25c9",  # Fisheye - ◉
              "\u25cf",  # Blank Circle - ●
              "\u2022",  # Bullet - ●
              "\u2b24"   # Blank Large Circle - ⬤

            @glyphs = glyphs
            @ranges = glyphs.ranges
            @indexes = 0 ... @ranges.length

          end

          def execute

            _row_a = @matrix.bundle.trails.map do | trail |
              __row_via_trail trail
            end

            Table_.new _row_a, @glyphs
          end

          def __row_via_trail trail

            row = ::Array.new @order_box_length

            st = Callback_::Stream.via_nonsparse_array trail

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

            d = bundle_filechange.fc.change_count

            idx = @indexes.detect do | d_ |

              @ranges.fetch( d_ ).include? d

            end

            idx or self._SANITY

            Modality_Filechange___.new false, idx, bundle_filechange
          end
        end

        Modality_Filechange___ = ::Struct.new :is_first, :amount_classification, :bundle_filechange

        class Glyphs___

          attr_reader :create_glyph, :glyphs, :ranges

          def initialize statistics, create_glyph, * glyphs

            @create_glyph = create_glyph

            s_length = statistics.length
            g_length = glyphs.length

            chunk_length = s_length / g_length

            d = 0

            range_a = []

            d_ = d + chunk_length

            begin_ = statistics.fetch d
            end_ = statistics.fetch d_

            end_value = statistics.fetch( -1 )

            begin

              range_a.push ::Range.new( begin_, end_ )

              if end_value == end_
                break
              end

              d = d_ + 1
              if s_length == d
                break
              end

              begin_ = statistics.fetch d
              d_ = d + chunk_length

              if s_length <= d_
                self._LOOK
              end

              end__ = statistics.fetch d_

              if end_ == begin_
                begin_ = end__
              end

              end_ = end__

              redo
            end while nil

            @glyphs = glyphs
            @ranges = range_a
          end
        end

        Table_ = self
      end
    end
  end
end
