module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class ClientForMagnetics___

      # (a stand-in for [#ta-005] the dream of magnetics..)

      class << self
        alias_method :begin_hot_session__, :new
        undef_method :new
      end  # >>

      def initialize acs, & p
        @appearance_ = acs
        @_listener = p
      end

      def build_imagemagick_command__
        _ok = resolve_IM_command_
        _ok && @IM_command_
      end

      # -- resolving the image

      def resolve_image_
        _touch :@image_, Here_::Magnetics_::Image_via_Appearance
      end

      attr_reader :image_

      # -- resolving the IM command

      def resolve_IM_command_
        _touch :@IM_command_, Here_::Magnetics_::Command_via_Appearance
      end

      # --

      def _touch ivar, p_ish

        if instance_variable_defined? ivar
          instance_variable_get( ivar ) ? ACHIEVED_ : UNABLE_
        else
          x = p_ish[ self, & @_listener ]
          instance_variable_set ivar, x  # cache the work whether succeeded or failed
          x ? ACHIEVED_ : UNABLE_
        end
      end

      def system_conduit_
        @appearance_.kernel_.silo( :Installation ).system_conduit
      end

      attr_reader(
        :appearance_,
        :IM_command_,
      )
    end
  end
end
