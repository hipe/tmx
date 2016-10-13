module Skylab::MyTerm

  class Terminal_Adapters_::Iterm

    # a "terminal mutation session"

    class << self
      alias_method :begin_terminal_mutation_session___, :new
      undef_method :new
    end  # >>

    def initialize magnetics, & oes_p
      @_oes_p = oes_p
      @_vendor_magnetics = magnetics
    end

    def set_background_image__
      _ok = _resolve_image
      _ok && __set_background_image_via_image
    end

    def build_OSA_script__
      _ok = resolve_OSA_script_
      _ok && @OSA_script_
    end

    # -- setting the background image

    def __set_background_image_via_image
      Magnetics_::Set_Background_Image_via_Image[ self, & @_oes_p ]
    end

    # -- resolving the OSA script

    def resolve_OSA_script_

      _ok = _resolve_image
      _ok && _init_if_necessary( :@OSA_script_, Magnetics_::OSA_Script_via_Image )
    end

    attr_reader :OSA_script_

    # -- resolving the image

    def _resolve_image
      _init_via_vendor_node :@image_, :image_, :resolve_image_
    end

    attr_reader :image_

    # --

    def check_version_of_iterm_
      @___CV_of_iT_qk ||= Magnetics_::Compatible_Version_of_Iterm[ self, & @_oes_p ]
      @___CV_of_iT_qk.value_x
    end

    def _init_via_vendor_node ivar, node_m, resolve_m

      ok = @_vendor_magnetics.send resolve_m
      if ok
        instance_variable_set ivar, @_vendor_magnetics.send( node_m )
        ACHIEVED_
      else
        ok
      end
    end

    def _init_if_necessary ivar, p_ish

      if instance_variable_defined? ivar
        instance_variable_get( ivar ) ? ACHIEVED_ : UNABLE_
      else
        x = p_ish[ self, & @_oes_p ]
        if x
          instance_variable_set( ivar, x ) ; ACHIEVED_
        else
          x
        end
      end
    end

    def system_conduit_
      @_vendor_magnetics.system_conduit_
    end

    Autoloader_[ Magnetics_ = ::Module.new ]
  end
end
# #history: broke off from its counterpart under the imagemagick node
