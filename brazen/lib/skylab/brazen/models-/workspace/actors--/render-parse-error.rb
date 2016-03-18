module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Render_parse_error

      Attributes_actor_.call( self,
        :properties,
        :y,
        :ev,
        :expag,
      )

      def execute

        y = @y ; o = @ev

        @expag.calculate do

          y << "#{ o.reason } in #{ pth o.input_identifier.to_path }:#{
            }#{ o.lineno }:#{ o.column_number }"

          hdr = "  #{ o.lineno }: "
          hdr_ = SPACE_ * hdr.length

          y << "#{ hdr }#{ o.line }"

          y << "#{ hdr_ }#{ DASH_ * ( o.column_number - 1 ) }^"

        end ; nil
      end
    end
  end
end
