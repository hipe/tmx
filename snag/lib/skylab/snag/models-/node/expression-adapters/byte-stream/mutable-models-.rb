module Skylab::Snag

  class Models_::Node

    module ExpressionAdapters::ByteStream

      Mutable_Models_ = ::Module.new

      class Mutable_Models_::Body < Row_Based_Body_

        class << self

          def via_range_and_substring_array__ r, row_a
            new r, row_a
          end
        end  # >>

        def initialize r, row_a
          @r = r
          @row_a = row_a
        end

        def prepend_component_ qk, & _

          obj = qk.value
          a = _mutable_row_at_index( @r.begin ).o_a_
          if a.length.nonzero?
            o = a.first
            if :space == o.category_symbol
              if WS__ !~ o.mutable_string[ 0 ]
                o.mutable_string[ 0, 0 ] = SPACE_
              end
            else
              a.unshift Space_piece_singleton__[]
            end
          end
          a.unshift obj
          ACHIEVED_
        end

        def append_component_ qk, & _

          obj = qk.value
          a = _mutable_row_at_index( @r.end - 1 ).o_a_
          if a.length.nonzero?
            o = a.last
            if :space == o.category_symbol
              if WS__ !~ o.mutable_string[ -1 ]
                o.mutable_string.concat SPACE_
              end
            else
              a.push Space_piece_singleton__[]
            end
          end
          a.push obj
          ACHIEVED_
        end

        Space_piece_singleton__ = Common_.memoize do

          Home_::Models::Hashtag::String_Piece.via_string SPACE_
        end

        def remove_component_ qk

          obj = qk.value
          did = false
          x = nil

          d = 0 ; len = @row_a.length
          row_st = Common_.stream do
            if d < len
              x = @row_a.fetch d
              d += 1
              x
            end
          end

          begin
            row_d = d
            row = row_st.gets
            row or break

            d_ = row.detect_index_of_equivalent_object_ obj, row_st
            if d_
              row = _mutable_row_at_index row_d
              a = row.o_a_
              x = a.fetch d_
              a[ d_, 1 ] = EMPTY_A_
              did = true
              break
            end
            redo
          end while nil

          if did
            x
          else
            self._SANTIY__redundancy_check_should_have_been_done_through_ACS
          end
        end

        def _mutable_row_at_index d

          x = @row_a.fetch d
          if x.is_mutable
            x
          else
            __convert_to_mutable_row d, x
          end
        end

        def __convert_to_mutable_row d, ss

          d_ = d ; last = @row_a.length - 1
          _row_st = Common_.stream do
            if d_ != last
              d_ += 1
              @row_a.fetch d_
            end
          end

          _a = ss.to_object_stream_( _row_st ).map_by do | o |  # because :+#flyweight
            o.dup
          end.to_a

          mutable = Row___.new _a

          @row_a[ d ] = mutable
          if d_ != d
            self._ERASE_MORE_ROWS
          end
          mutable
        end

        def to_business_row_stream_

          a = @row_a

          Common_::Stream.via_range @r do | d |
            a.fetch d
          end
        end

        def r_
          @r
        end

        def row_a_
          @row_a
        end

        def is_mutable
          true
        end

        def modality_const  # #experimental mechanic
          :ByteStream
        end

        class Row___

          def initialize o_a
            @o_a_ = o_a
          end

          attr_reader :o_a_

          def is_mutable
            true
          end

          def to_object_stream_ _
            Common_::Stream.via_nonsparse_array @o_a_
          end
        end
      end
    end
  end
end
