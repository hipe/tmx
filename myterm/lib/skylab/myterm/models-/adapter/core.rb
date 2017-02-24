module Skylab::MyTerm

  module Models_::Adapter

    class << self

      def interpret_component st, cust, & pp

        Adapter_via_Argument_Stream___[ st, cust.kernel_, & pp ]
      end
    end  # >>

    class Adapter_via_Argument_Stream___ < Common_::Dyadic

      def initialize st, k, & pp
        @_arg_st = st
        @kernel_ = k
        @_pp = pp
      end

      def execute

        _ok = __resolve_loadable_reference_via_argument_stream
        _ok and Instance.__via_selection_loadable_reference @_loadable_reference, @kernel_
      end

      def __resolve_loadable_reference_via_argument_stream

        _adapters_silo = @kernel_.silo :Adapters
        _stream_method = _adapters_silo.method :to_asset_reference_stream

        _x = @_arg_st.head_as_is

        @_oes_p = @_pp[ nil ]

        o = Common_fuzzy_retrieve_[].new( & @_oes_p )

        o.name_map = -> lt do
          lt.stem
        end

        o.stream_builder = -> do
          _adapters_silo.to_asset_reference_stream
        end

        o.set_qualified_knownness_value_and_symbol _x, :adapter_name

        lt = o.execute
        if lt
          remove_instance_variable( :@_arg_st ).advance_one
          @_loadable_reference = lt
          ACHIEVED_
        else
          lt
        end
      end
    end

    class Instance

      # yes, this name is perhaps awful #todo-maybe.
      # read #spot-1 - this is the invocation-time-only instance of the
      # adapter.

      class << self

        def __via_selection_loadable_reference lt, ke
          new_prototype_( ke ).__init_as_selected lt
        end

        alias_method :new_prototype_, :new
        undef_method :new
      end  # >>

      def initialize ke
        @kernel_ = ke
      end

      # ~

      def __init_as_selected lt
        @_is_selected = true
        _init_via_loadable_reference lt
      end

      # ~

      def new_not_selected_ lt
        dup.___init_not_selected lt
      end

      def ___init_not_selected lt
        @_is_selected = false
        _init_via_loadable_reference lt
      end

      # ~

      def _init_via_loadable_reference lt

        @_impl = lt.module.new self
        @_loadable_reference = lt
        @_rw = ACS_::ReaderWriter.for_componentesque @_impl
        self
      end

      # --

      # -- Expressive event hook-ines/hook-outs

      def express_into_under y, expag  # for modality clients

        nf = name
        yes = @_is_selected

        expag.calculate do

          _glyph = yes ? GLYPH_FOR_IS_SELECTED___ : GLYPH_FOR_IS_NOT_SELECTED___

          y << "#{ _glyph }#{ nm nf }"
        end
      end

      GLYPH_FOR_IS_SELECTED___ = '• '
      GLYPH_FOR_IS_NOT_SELECTED___ = '  '

      def description_under expag  # for expressive events
        nf = name
        expag.calculate do
          nm nf
        end
      end

      # -- our own personal adapter implementation API (parallels axiomatic ops)

      def association_if_associated__ token_x

        # in order to blahblah, it is we not they that do the checking here
        # note that this method amounts to a variation of phrasing -
        # fortunately our dependee method does exactly what we want already.

        @_rw.read_association token_x
      end

      def read_formal_operation__ sym
        @_rw.read_formal_operation sym
      end

      def read_value__ asc

        # what we are *supposed* to implement is "give me the kn for this
        # IFF it is an associated association". since that's more API than
        # we think we need, we instead answer an easier question ("do we
        # know the value?") and posit that the net effect will be the same..

        kn = @_rw.read_value asc
        if kn.is_known_known
          kn
        end
      end

      def write_value_if_associated__ qk

        # the thing we dodged in the above method..

        _yes = @_rw.has_an_association_definition_for qk.association.name_symbol
        if _yes
          @_rw.write_value qk
          ACHIEVED_
        end
      end

      # --

      def adapter_name_const
        name.as_const
      end

      def name
        @_loadable_reference.adapter_name
      end

      def implementation_
        @_impl
      end

      def path
        @_loadable_reference.path
      end

      def reader_writer__
        @_rw
      end

      attr_reader(
        :kernel_,
      )
    end

    IDENTITY_ = -> x { x }
  end
end
