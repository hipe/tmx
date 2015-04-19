module Skylab::Snag

  class Models_::Node

    Expression_Adapters = ::Module.new

    module Expression_Adapters::Byte_Stream

      class << self

        def express_into_under_of_ y, expag, node
          express_N_units_into_under_of_ nil, y, expag, node
        end

        def express_N_units_into_under_of_ d, y, expag, node

          body = node.body

          if body.is_mutable
            if :Byte_Stream == body.modality_const
              Sessions_::Delineate[ d, y, expag, node ]
            else
              Sessions_::Delineate.new_with( d, y, expag, node ).execute_agnostic
            end
          else
            self.__TODO_express_immutable_body
          end
        end
      end  # >>

      Autoloader_[ Sessions_ = ::Module.new ]

      class Sessions_::Expag___  # will integrate

        def initialize d, d_, d__

          @identifier_integer_width = d__
          @sub_margin_width = d_
          @width = d
          @modality_const = :Byte_Stream
        end

        attr_reader :identifier_integer_width, :modality_const,
          :sub_margin_width, :width
      end

      Actors_ = ::Module.new

      Actors_::Flyweighted_object_stream_via_substring = -> do

        # to leverage (rather than be penalized by) the flyweighting that the
        # upstream provides (see), we must re-use the same stream object over
        # all of the upstream lines.

        p = -> sstr do  # the first time it its called ..

          fly = Snag_::Models::Hashtag::Stream[
            :input_string, sstr.s,
            :hashtag_class,
            Snag_::Models_::Tag::Expression_Adapters::Byte_Stream::Models_::Tag
          ].to_name_value_scanner

          scn = fly.string_scanner
          scn.pos = sstr.begin
          fly.end = sstr.end

          p = -> sstr_ do  # subsequent times ..

            scn = fly.string_scanner
            scn.string = sstr_.s
            scn.pos = sstr_.begin
            fly.end = sstr_.end
            fly
          end

          fly
        end

        -> sstr do
          p[ sstr ]
        end
      end.call

      BS_ = self
    end
  end
end
