self._NOT_USED  # #open [#073]

module Skylab::Brazen

  class Models_::Workspace

    class Magnetics::ExpressError_via_ConfigParseException

      Attributes_actor_.call( self,
        :properties,
        :y,
        :ev,
        :expag,
      )

      def execute

        y = @y ; o = @ev

        @expag.calculate do

          y << "#{ o.reason } in #{ pth o.byte_upstream_reference.to_path }:#{
            }#{ o.lineno }:#{ o.column_number }"

          hdr = "  #{ o.lineno }: "
          hdr_ = SPACE_ * hdr.length

          y << "#{ hdr }#{ o.line }"

          y << "#{ hdr_ }#{ DASH_ * ( o.column_number - 1 ) }^"

        end ; nil
      end

      # ==
      # ==
    end
  end
end
