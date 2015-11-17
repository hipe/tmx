module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003])

    # -- Construction methods

    class << self

      def interpret_compound_component p, asc, acs, & oes_p

        p[ new asc, acs, & oes_p ]
      end

      private :new
    end  # >>

    # -- Initializers

    def initialize asc, acs, & oes_p

      @kernel_ = acs.kernel_
      @_nf = asc.name
      @oes_p_ = oes_p
    end

    def mutate_by_becoming_selected_
      @is_selected = true ; nil
    end

    def mutate_by_becoming_not_selected__
      @is_selected = false ; nil
    end

    # -- Expressive event & modality hook-ins/hook-outs

    def express_into_under y, expag  # for modality clients

      nf = adapter_name
      yes = @is_selected

      expag.calculate do

        _glyph = yes ? GLYPH_FOR_IS_SELECTED___ : GLYPH_FOR_IS_NOT_SELECTED___

        y << "#{ _glyph }#{ nm nf }"
      end
    end

    GLYPH_FOR_IS_SELECTED___ = '• '
    GLYPH_FOR_IS_NOT_SELECTED___ = '  '

    entity_name = nil
    define_method :name do  # while #open [#br-107]
      entity_name ||= Callback_::Name.via_variegated_symbol :image_output_adapter
    end

    # -- ACS hook-ins

    # (the next 2 are what is default, but #note-about-explicit-readers-writers)

    def accept_component_qualified_knownness qkn
      @___value_writer ||= ACS_[]::Reflection::Ivar_based_value_writer[ self ]
      @___value_writer[ qkn ]
    end

    def component_wrapped_value asc
      @___value_reader ||= ACS_[]::Reflection::Ivar_based_value_reader[ self ]
      @___value_reader[ asc ]
    end

    # -- Components

    def __background_font__component_association

      # yield :required_to_make_image

      Home_::Models_::Font
    end

    # -- ACS hook-outs  (implement primitive-esque operations)

    def __set__primitivesque_component_operation_for qkn

      yield :description, -> y do
        y << "set #{ qkn.name.as_human }"
      end

      -> x do

        _vp = ACS_[]::Interpretation::Value_Popper[ x ]

        _oes_p_ = ACS_[]::Interpretation::Component_handler[
          qkn.association, self ]

        wv = qkn.association.component_model[ _vp, & _oes_p_ ]
        if wv
          self._K
        else
          wv
        end
      end
    end

    def __get__primitivesque_component_operation_for qkn

      yield :description, -> y do
        y << "get #{ qkn.name.as_human }"
      end

      -> do
        self._CONSIDER_THIS_CAREFULLY
      end
    end

    # -- ACS signal handling

    def component_event_model
      :hot
    end

    def receive_component__change__ asc, & new_component_p

      # one of our immediate components is emitting a new component that
      # should serve as a replacement for it. we do the swap here and we
      # emit upwards a "mutation" event signaling that something changed

      _new_component = new_component_p[]

      _ev_p = ACS_[]::Interpretation::Accept_component_change[
        _new_component, asc, self ]

      _ev = _ev_p[]

      _ctx = Begin_context_[ asc.name, _ev ]

      persisted_OK = @oes_p_.call :mutated do
        _ctx
      end

      if persisted_OK
        ___when_persisted_OK
      else
        persisted_OK
      end
    end

    def ___when_persisted_OK
      ACHIEVED_  # this will become etc..
    end

    # ~  error and info

    def receive_component__error__ asc, desc_sym, & ev_p

      @oes_p_.call :error, desc_sym do

        Add_context_[ asc.name, ev_p[] ]
      end

      UNABLE_
    end

    def receive_component__info__  # respond to only
    end

    def receive_component__info__expression__ asc, desc_sym, & y_p

      @oes_p_.call :info, :expression, desc_sym do | y |

        ACS_[]::Modalities::Human::Contextualize_lines[ y, self, asc, nil, & y_p ]
      end
    end

    def receive__component__is_not__ * rest, asc, & p

      @oes_p_.call :component, :is_not, * rest, asc, & p

    end

    # -- Project hook-ins/hook-outs

    def read_for_interface__ qkn

      @___read_for_interface ||= ___build_read_for_interface
      @___read_for_interface[ qkn ]
    end

    def ___build_read_for_interface

      # this is a request by our "GRAND-CUSTODIAN" to build an "injected"
      # component. we build it as we would one of our own. (it *is* one of
      # our own.) the difference is in how we handle the events.

      touch = ACS_[]::For_Interface::Touch

      -> qkn_x do

        touch[ qkn_x, self ]
      end
    end

    def adapter_name_const
      @_nf.as_const
    end

    def adapter_name
      @_nf
    end

    def path
      @_nf.path
    end

    attr_reader(
      :is_selected,
      :kernel_,
    )
  end
end
