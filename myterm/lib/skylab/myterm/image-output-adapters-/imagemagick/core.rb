module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc

      @_svc = svc
      @_unavailability = method :__image_gen_related_component_unavailability
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

      yield :description, -> y do
        y << "just show the AppleScript that talks to iTerm (debugging)"
      end

      -> & call_p do

        if 1 == call_p.arity
          self._MODERNIZE_ME_or_figure_this_out  # #todo
        end

        _begin_terminal_mutation_session( & call_p ).build_OSA_script__
      end
    end

    def __imagemagick_command__component_operation

      yield :description, -> y do
        y << "just show the command-line `convert` arguments (debugging)"
      end

      yield :unavailability, @_unavailability

      -> & call_p do
        _begin_IM_session( & call_p ).build_imagemagick_command__
      end
    end

    def __image_gen_related_component_unavailability _fo

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
          Common_::Known_Known[ :_was_written_ ]  # ick/meh
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

    # ~ non-requireds below here

    # (`default` does nothing presently)

    def __pointsize__component_association

      yield :description, -> y do
        y << "in this context, larger pointsize means more pixels.."
      end

      # an aesthetically appropriate value depends on the (pixel) `size`
      # of the image being generated.

      # yield :default, 90  # this is annoying until [#ze-042] clearable

      Home_.lib_.basic::Number.component_model_for :POSITIVE_INTEGER
    end

    def __fill_color__component_association

      yield :description, -> y do
        y << "sets the 'fill' (color) of the generated image (text)"
      end

      yield :default, :grey

      yield :internal_name, :fill

      Home_::Models_::Color
    end

    def __background_color__component_association

      yield :description, -> y do
        y << "sets the 'background' (color) of the generated image"
      end

      yield :default, :transparent

      yield :internal_name, :background

      Home_::Models_::Color
    end

    def __size__component_association

      # (note, despite association caching the below beast might be built
      # multiple times in one invocation - WHY)

      yield :description, -> y do
        y << "\"HxW\" in pixels"
      end

      yield :default, '720x720'

      # (for reference, macbook air 13" screen resolution is 1440x900)
      # (we don't understand this fully yet, but square dimensions seem
      #  to be what you want.)

      Home_.lib_.basic::Regexp.build_component_model do |o|

        o.matcher = /\A(\d+)[xX](\d+)\z/

        o.mapper = -> w_s, h_s do

          # so that this is ready to be sent to the backend,
          # we actually go and convert this back to a string

          "#{ w_s }x#{ h_s }"
        end

        o.on_failure_to_match = -> _reserved, & oes_p do

          oes_p.call :error, :expression, :is_not, :width_height do | y |
            y << "must be of the form \"123x456\""
          end
        end
      end
    end

    def __gravity__component_association

      yield :generate_description

      yield :default, :northeast

      Home_.lib_.basic::String.component_model_for :NONBLANK_TOKEN
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
  end
end
