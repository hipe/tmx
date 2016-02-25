module Skylab::Zerk

  module Invocation_

    class Procure_bound_call

      # [#027]:"procure bound call"

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize pvs, fo, & pp
        @_formal = fo
        @_on_u = nil
        @_pp = pp
        @PVS = pvs
      end

      Require_ACS_[]

      def on_unavailable_= x
        @_on_u = Callback_::Known_Known[ x ] ; x  # #[#sl-156]
      end

      def execute

        omni_handler = -> * i_a, & ev_p do
          omni_handler = @_pp[ NOTHING_ ]  # there might be a cost?
          omni_handler.call( * i_a, & ev_p )
          UNRELIABLE_
        end

        o = @_formal.begin_preparation( & omni_handler )

        @_index_everything_once = -> do
          remove_instance_variable :@_index_everything_once
          __index_everything_which_is_a_heavy_lift
        end

        @_bespoke_stream_once = -> do
          remove_instance_variable :@_bespoke_stream_once  # sanity
          @_index_everything_once[]
          @__bespoke_stream
        end

        @_expanse_stream_once = -> do
          remove_instance_variable :@_expanse_stream_once
          __expanse_stream_without_having_built_bespoke_stream
        end

        o.bespoke_stream_once = -> do
          @_bespoke_stream_once[]
        end

        o.expanse_stream_once = -> do
          @_expanse_stream_once[]
        end

        o.on_unavailable_ = @_on_u ? @_on_u.value_x : omni_handler

        o.parameter_store = self  # so "as parameter store" below

        o.parameter_value_source = @PVS

        @_real_store = @_formal.begin_parameter_store( & omni_handler )
        @_accept_to_real_store = @_real_store.method( :accept_parameter_value )

        o.to_bound_call
      end

      # multiple of the below methods may rely on:
      #
      #   • [#ac-028]:#API-point-A, which stipulates that bespoke parameters
      #     will NOT be requested if the parameter value source is known
      #     to be empty.
      #
      #   • [#ac-028]:#API-point-B, which stipulates that every of the
      #     "expanse set" parameters will be read from during the
      #     normalization step.

      def __expanse_stream_without_having_built_bespoke_stream

        # more backflips to avoid the "heavy lift": assume we are here
        # because the parameter value source was empty. if also the formal
        # operation has no stated parameters, then we can procede without
        # the "heavy lift". otherwise do..

        st = @_formal.to_defined_formal_parameter_stream
        x = st.gets
        if x
          @_expanse_stream_once = nil
          @_index_everything_once[]
          p = -> do
            p = st
            x
          end
          Callback_.stream do
            p[]
          end
        else
          @_value_reader_proc = :_NEVER_CALLED_
          Callback_::Stream.the_empty_stream
        end
      end

      def __index_everything_which_is_a_heavy_lift

        # since it is a "heavy lift" to derive the bespoke stream (because
        # we have to index every frame), we do this only when we have to.

        means_h = {}

        stated_bx = @_formal.to_defined_formal_parameter_stream.
          flush_to_box_keyed_to_method :name_symbol

        pool = stated_bx.a_.dup
        pool_h = ::Hash[ pool.each_with_index.map { |*a| a } ]

        # --

        frame_index_via_name_symbol = Callback_::Box.new
        my_stack = []

        frame_d = 0
        parent_index = nil

        st = ___to_frame_stream
        fr = st.gets
        begin

          idx = Here_::Frame_Index___.new fr, parent_index do |no|

            k = no.name_symbol
            frame_index_via_name_symbol.add k, frame_d
            d = pool_h[ k ]
            if d
              means_h[ k ] = :__lookup_knownness_socialistically_and_write_to_real_store
              pool[ d ] = nil
            end
          end

          my_stack.push idx
          fr = st.gets
          fr or break
          parent_index = idx
          frame_d += 1
          redo
        end while nil

        @_index_stack = my_stack
        @_soc_h = frame_index_via_name_symbol.h_

        # --

        remove_instance_variable :@_expanse_stream_once  # assert it wasn't called yet
        @_expanse_stream_once = -> do
          remove_instance_variable :@_expanse_stream_once
          _ = stated_bx.to_value_stream
          _
        end

        pool.compact!
        pool.each do |k_|
          means_h[ k_ ] = :__lookup_knownness_for_bespoke_parameter
        end
        _st = Callback_::Stream.via_nonsparse_array pool
        @__bespoke_stream = _st.map_by do |k_|
          stated_bx.fetch k_
        end

        @_value_reader_proc = -> par, & els do

          kn = send means_h.fetch( par.name_symbol ), par

          if kn.is_known_known
            kn.value_x
          else
            els[]
          end
        end

        NIL_
      end

      def ___to_frame_stream

        ss = @_formal.selection_stack
        Callback_::Stream.via_range( 0 .. ss.length - 2 ) do |d|
          ss.fetch d
        end
      end

      def __lookup_knownness_for_bespoke_parameter par
        @_real_store.knownness_for par
      end

      def __lookup_knownness_socialistically_and_write_to_real_store par

        # very tricky -  whether the formal is proc-implemented or non-proc-
        # implemented; of the parameters in the "stated set" that are known
        # in our "scope stack", each of these parameter values needs to be
        # written to the real store for the actual invocation.
        #
        # per [#ac-028]:#API-point-B we are being called once for each
        # parameter of the "stated set" ("expanse" there) in order to apply
        # defaults and find missing required parameters.
        #
        # here we piggy back on that loop to accomplish this first part too!

        _idx = @_index_stack.fetch @_soc_h.fetch par.name_symbol
        kn = _idx.lookup_knownness__ par

        if kn.is_known_known
          @_accept_to_real_store[ kn.value_x, par ]
        end
        kn
      end

      # -- "as parameter store"

      def accept_parameter_value x, par
        @_accept_to_real_store[ x, par ]
      end

      def value_reader_proc
        @_value_reader_proc
      end

      def internal_store_substrate
        @_real_store.internal_store_substrate
      end
    end
  end
end
# #history - distilled from the API invocation mechanism & formal operations.
