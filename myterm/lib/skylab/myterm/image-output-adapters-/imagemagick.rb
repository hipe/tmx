module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    # -- Construction methods

    class << self

      def interpret_compound_component p, asc, acs, & x_p

        p[ new asc, acs, & x_p ]
      end

      private :new
    end  # >>

    # -- Initializers

    def initialize asc, acs, & oes_p_p

      @is_selected = false
      @kernel_ = acs.kernel_
      @_nf = asc.name

      @oes_p_ = oes_p_p[ self ]
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

    def component_association_reader
      @___car ||= Component_Association___[].caching_method_based_reader_for self
    end

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

      yield :required_to_make_image

      yield :internal_name, :font

      Home_::Models_::Font
    end

    def __label__component_association

      yield :required_to_make_image

      yield :can, :set, :get

      yield :generate_description

      Home_.lib_.basic::String.component_model_for :NONBLANK
    end

    # -- ACS hook-outs (implement primitive-esque operations)

    # ~ primitivesque setting

    def __set__primitivesque_component_operation_for qkn

      yield :description, -> y do
        y << "set #{ qkn.name.as_human }"
      end

      yield :parameter, :x, :name, qkn.name

      -> x do
        ___set_primitivesque x, qkn
      end
    end

    def ___set_primitivesque x, qkn

      asc = qkn.association

      wv = ___for_set_build_primitive x, asc

      wv and __accept_primitive wv, qkn
    end

    def ___for_set_build_primitive x, asc

      _oes_p_p = -> _ do

        -> * i_a, & ev_p do  # experiment :#in-situ-1:

          _LL = Linked_list_[].via asc.name, :set, ev_p

          @oes_p_.call i_a.fetch( 0 ), :contextualized, * i_a[1..-1] do
            _LL
          end
        end
      end

      _vp = ACS_[]::Interpretation::Value_Popper[ x ]

      asc.component_model[ _vp, & _oes_p_p ]
    end

    def __accept_primitive wv, qkn

      _ev_proc = ACS_[]::Interpretation::Accept_component_change[
        wv.value_x, qkn, self ]

      _LL = Linked_list_[].via qkn.name, _ev_proc  # #no-verb

      _send_mutation _LL
    end

    def __get__primitivesque_component_operation_for qkn

      yield :description, -> y do
        y << "get #{ qkn.name.as_human }"
      end

      -> do
        if qkn.is_effectively_known
          x = qkn.value_x
          if x.respond_to? :ascii_only?
            x
          else
            self._COVER_ME  # watch for etc
          end
        else
          @oes_p_.call :info, :expression, :not_set do | y |
            y << "(no value set for #{ qkn.name.as_human })"
          end
          NIL_
        end
      end
    end

    # -- ACS signal handling

    def component_event_model
      :hot
    end

    def receive_component__change__ qkn, & new_component_p

      # one of our immediate components is emitting a new component that
      # should serve as a replacement for it. we do the swap here and we
      # emit upwards a "mutation" event signaling that something changed

      _new_component = new_component_p[]

      _ev_p = ACS_[]::Interpretation::Accept_component_change[
        _new_component, qkn, self ]

      o = Linked_list_[]
      _end = o[ nil, _ev_p ]
      _LL = o[ _end, qkn.name ]

      _send_mutation _LL
    end

    def receive_component_event qkn, i_a, & x_p

      if :info == i_a.first  # we never add context to info's

        @oes_p_[ * i_a, & x_p ]

      elsif :contextualized == i_a[ 1 ]

        # a component gave us a contextualized signal. add its own
        # name to the linked list of context and propagate upwards

        _LL = x_p[]

        _LL_ = Linked_list_[][ _LL, qkn.name ]

        @oes_p_.call( * i_a ) do
          _LL_
        end
      else
        self._UNEXPECTED_emission_channel
      end
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

    # -- Support

    def _send_mutation _LL

      persisted_OK = @oes_p_.call :mutation do
        _LL
      end

      if persisted_OK
        ___maybe_build_and_send_image
      else
        persisted_OK
      end
    end

    # ~ (see [#004]:principal-algorithm-1 - when images are made)

    def ___maybe_build_and_send_image

      _yes = __check_if_all_requireds_are_set
      if _yes
        __via_snapshot_build_and_send_image
      else
        ACHIEVED_  # missing requireds is not a failure
      end
    end

    def __check_if_all_requireds_are_set

      # all about this name and implementation at [#004]:subnote-1

      missing = nil
      snapshot = Callback_::Box.new  # stowaway logic while making the trip

      st = ACS_[]::Reflection::To_qualified_knownness_stream[ self ]

      begin

        qkn = st.gets
        qkn or break

        snapshot.add qkn.name.as_variegated_symbol, qkn

        if ! qkn.association.is_required_to_make_image_
          redo
        end

        if ! qkn.is_effectively_known
          ( missing ||= [] ).push qkn.association
        end

        redo
      end while nil

      if missing
        ___emit_information_about_remaining_required_fields missing
        UNABLE_
      else
        @snapshot_ = snapshot
        ACHIEVED_
      end
    end

    def ___emit_information_about_remaining_required_fields missing

      @oes_p_.call :info, :expression, :remaining_required_fields do | y |

        _s_a = missing.map do | asc |
          val asc.name.as_human  # ..
        end

        y << "(still needed before we can produce an image: #{ and_ _s_a })"
      end

      NIL_
    end

    # -- personal

    def __via_snapshot_build_and_send_image

      Here_::Build_and_send_image_[ @snapshot_, @kernel_, & @oes_p_ ]
    end

    Here_ = self
  end

  Image_Output_Adapters_::Imagemagick::Component_Association___ = Callback_.memoize do

    # in keeping with tradition we only ever load ACS libs lazily

    class Component_Association < ACS_[]::Component_Association

      def accept__internal_name__meta_component x
        @__internal_name_symbol = x
        NIL_
      end

      def get_internal_name_string__

        sym = __internal_name_symbol
        if sym
          sym.id2name
        else
          # @name.as_slug.gsub DASH_, EMPTY_S_  # for example
          @name.as_slug
        end
      end

      # "requiredness" is a business-specific concern - it is not modeled
      # by the ACS (nor should it be). but because it is a useful concept
      # here, we can enrich our DSL to recognize this meta-component:

      def accept__required_to_make_image__meta_component
        @is_required_to_make_image_ = true
        NIL_
      end

      attr_reader(
        :__internal_name_symbol,
        :is_required_to_make_image_,
      )

      DASH_ = '-'
      EMPTY_S_ = ''

      self
    end
  end
end
