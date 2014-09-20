module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Render_parse_error

      Actor_[ self, :properties, :y, :ev, :expag ]

      def execute

        y = @y ; o = @ev

        @expag.calculate do

          y << "#{ o.reason } in #{ pth o.input_identifier.to_path }:#{
            }#{ o.line_number }:#{ o.column_number }"

          hdr = "  #{ o.line_number }: "
          hdr_ = SPACE_ * hdr.length

          y << "#{ hdr }#{ o.line }"

          y << "#{ hdr_ }#{ DASH_ * ( o.column_number - 1 ) }^"

        end ; nil
      end
    end
  end
end
