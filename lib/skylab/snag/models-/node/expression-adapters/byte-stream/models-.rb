module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream  # [#038]

      Models_ = ::Module.new

      class Models_::Substring

        def initialize begin_, end_, string
          @begin = begin_
          @end = end_
          @s = string
        end

        attr_reader :begin, :end, :s

        def is_mutable
          false
        end

        def to_mutable
          BS_::Mutable_Models_::Substring.new @begin, @end, @s.dup
        end

        def to_simple_stream_of_objects_

          # for one line of one node, produce the strings and tags. this
          # will be used in whole-collection searched for tags, so etc..

          BS_::Actors_::Flyweighted_object_stream_via_substring[ self ]
        end

        alias_method :to_object_stream_, :to_simple_stream_of_objects_
          # we can do the above only while we using [#008] structured tags,
          # which result in a common stream as a by-product; else :+#tombstone

      end

      class Models_::Body

        class << self
          def via_range_and_substring_array r, sstr_a
            new r, sstr_a
          end
          private :new
        end  # >>

        def initialize r, sstr_a
          @r = r
          @sstr_a = sstr_a
        end

        def receive_extended_content_adapter__ x
          @extended_content_adapter_ = x
          NIL_
        end

        attr_reader :extended_content_adapter_

        def reinitialize r
          @r = r
          NIL_
        end

        def initialize_copy _
          @sstr_a = @sstr_a.dup
          NIL_
        end

        def is_mutable
          false
        end

        def to_mutable
          BS_::Mutable_Models_::Body.
            via_range_and_substring_array__( @r, @sstr_a.dup )
        end

        def entity_stream_via_model cls

          sym = cls.category_symbol

          __to_object_stream.reduce_by do | x |
            sym == x.category_symbol
          end
        end

        def __to_object_stream

          __to_business_row_stream.expand_by do | row |
            row.to_simple_stream_of_objects_
          end
        end

        def __to_business_row_stream

          a = @sstr_a

          Callback_::Stream.via_range @r do | d |
            a.fetch d
          end
        end
      end
    end
  end
end
