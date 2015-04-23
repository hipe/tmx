module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream

      Mutable_Models_ = ::Module.new

      class Mutable_Models_::Body

        class << self

          def via_range_and_substring_array__ r, row_a
            new r, row_a
          end
        end  # >>

        def initialize r, row_a
          @r = r
          @row_a = row_a
        end

        def is_mutable
          true
        end

        def modality_const  # #experimental mechanic
          :Byte_Stream
        end

        def r_
          @r
        end

        def row_a_
          @row_a
        end

        def __prepend__object_ obj, & oes_p

          a = _mutable_row_at_index( @r.begin ).o_a_
          if a.length.nonzero?
            o = a.first
            if :space == o.category_symbol
              if WS__ !~ o.mutable_string[ 0 ]
                o.mutable_string[ 0, 0 ] = SPACE_
              end
            else
              a.unshift Snag_::Models::Hashtag::String_Piece.new SPACE_
            end
          end
          a.unshift obj
          ACHIEVED_
        end

        def __append__object_ obj, & oes_p

          a = _mutable_row_at_index( @r.end - 1 ).o_a_
          if a.length.nonzero?
            o = a.last
            if :space == o.category_symbol
              if WS__ !~ o.mutable_string[ -1 ]
                o.mutable_string.concat SPACE_
              end
            else
              a.push Snag_::Models::Hashtag::String_Piece.new SPACE_
            end
          end
          a.push obj
          ACHIEVED_
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

          _a = ss.to_object_stream_.map_by do | o |  # because :+#flyweight
            o.dup
          end.to_a

          mutable = Row___.new _a

          @row_a[ d ] = mutable
          mutable
        end

        class Row___

          def initialize o_a
            @o_a_ = o_a
          end

          attr_reader :o_a_

          def is_mutable
            true
          end

          def to_object_stream_
            Callback_::Stream.via_nonsparse_array @o_a_
          end

          alias_method :to_simple_stream_of_objects_, :to_object_stream_
        end
      end
    end
  end
end
