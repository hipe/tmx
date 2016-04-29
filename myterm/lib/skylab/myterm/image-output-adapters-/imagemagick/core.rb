module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc

      @_svc = svc
      @_unavailability = method :__image_gen_related_component_unavailability
      @_use_cached_unavailability = false
    end

    # -- Operations

    def __set_background_image__component_operation

      yield :unavailability, @_unavailability

      yield :description, -> y do
        y << "(the main thing of this whole thing)"
      end

      -> & call_p do

        x = _begin_terminal_mutation_session( & call_p ).set_background_image__
        ACHIEVED_ == x and x = NOTHING_
        x
      end
    end

    def __OSA_script__component_operation

      yield :unavailability, @_unavailability

      -> & call_p do

        if 1 == call_p.arity
          self._MODERNIZE_ME_or_figure_this_out  # #todo
        end

        _begin_terminal_mutation_session( & call_p ).build_OSA_script__
      end
    end

    def __imagemagick_command__component_operation

      yield :unavailability, @_unavailability

      -> & call_p do
        _begin_IM_session( & call_p ).build_imagemagick_command__
      end
    end

    def __image_gen_related_component_unavailability _fo

      if @_use_cached_unavailability
        @_cached_unavailability
      else
        @_use_cached_unavailability = true   # #open [#014] - at #milestone-8 maybe use [ze] index instead
        x = ___determine_image_generational_unavailability
        @_cached_unavailability = x
        x
      end
    end

    def ___determine_image_generational_unavailability

      _rw = @_svc.reader_writer__

      _o = Home_::Image_Output_Adapter::Normalize_Components.call(
        _rw, :is_required_to_make_image_ )

      _o.to_unavailability
    end

    def _begin_terminal_mutation_session & oes_p

      _ = _begin_IM_session( & oes_p )
      Home_::Terminal_Adapters_::Iterm.begin_terminal_mutation_session___( _, & oes_p )
    end

    def _begin_IM_session & oes_p
      Here_::Session___.begin_hot_session__ self, & oes_p
    end

    # -- Components

    def __bg_font__component_association

      # because we need it to be reachable in one go for niCLI (as an
      # option), we semi-redundantly have to "hand write" this "alias"
      # to the real operation. ignore this from API, mask this in iCLI.

      # #todo three times!?

      yield :description, -> do
        "(the ability to set the font from this frame)"
      end

      yield :is_used_to_make_image, false

      -> st, & oes_p do

        @background_font ||= Home_::Models_::Font.interpret_compound_component IDENTITY_, nil, self

        kn = @background_font.interpret_path_ st, & oes_p

        if kn
          @background_font.accept_path__ kn
          Callback_::Known_Known[ :_was_written_ ]  # ick/meh
        else
          kn
        end
      end
    end

    def __background_font__component_association

      yield :required_to_make_image

      yield :internal_name, :font

      Home_::Models_::Font
    end

    def __label__component_association

      yield :required_to_make_image

      yield :generate_description

      Home_.lib_.basic::String.component_model_for :NONBLANK
    end

    # --

    def component_association_reader  # [ac] hook-in - opt-in to using this one

      Home_::Image_Output_Adapter::Common_Component_Association.
        reader_of_component_associations_by_method_in self
    end

    def kernel_
      @_svc.kernel_
    end

    Here_ = self
    IDENTITY_ = -> x { x }
    module Magnetics_
      Autoloader_[ self ]
    end
  end
end
