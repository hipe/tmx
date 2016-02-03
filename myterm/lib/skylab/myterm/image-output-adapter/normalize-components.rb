module Skylab::MyTerm

  module Image_Output_Adapter

    class Normalize_Components < Callback_::Actor::Dyadic

      # the logical essence of this is just a plain old #[#br-087]-style
      # missing-required's-check. it's noisy because it needs a lot of
      # custom fittings inbound & out.

      # always result in the same shape of custom result struct (bottom).
      #   • towards [#004]:principal-algorithm-1 - when images are made
      #   • fun: [#004]:"we used to abstain from calling this normalize"

      def initialize rw, mcmp_sym
        @metacomponent_symbol = mcmp_sym
        @_rw = rw
      end

      def execute

        # for each component assocation (i.e each node that is not a formal
        # operation), if it's required and "missing" then make a memo of it
        # and go into "error reporting mode" (below). otherwise add a qk
        # of the node to a box. "error reporting mode" simply means etc.

        st = ___build_node_stream

        @_see = method :__normal_see
        @_finish = method :__normal_finish
        @_snapshot = Callback_::Box.new

        begin
          no = st.gets
          no or break
          _qk = no.to_qualified_knownness
          @_see[ _qk ]
          redo
        end while nil

        @_finish.call
      end

      def ___build_node_stream

        o = @_rw.to_node_streamer
        o.on_operation = MONADIC_EMPTINESS_
        o.execute
      end

      def __normal_see qk

        if _invalid qk
          @_nerp = []
          _add_invalid qk
          @_see = method :___abnormal_see
          @_finish = method :__abnormal_finish
        else
          @_snapshot.add :k, :qkn
        end
        NIL_
      end

      def ___abnormal_see qk
        if _invalid qk
          _add_invalid qk
        end
        NIL_
      end

      def _invalid qk
        _asc = qk.association
        _is_required = _asc.send @metacomponent_symbol
        if _is_required
          ! qk.is_effectively_known
        end
      end

      def _add_invalid qk
        @_nerp.push qk.association ; nil
      end

      def __normal_finish
        _sn = remove_instance_variable :@_snapshot
        Result__.new NO_ERRORS_, IS_AVAILABLE___, _sn
      end

      def __abnormal_finish

        _em_proc = -> do

          missing = @_nerp

          _p = -> y do

            _s_a = missing.map do |asc|
              val asc.name.as_human  # ..
            end

            y << "(still needed before we can produce an image: #{ and_ _s_a })"
          end

          [ :info, :expression, :remaining_required_fields, _p ]
        end

        Result__.new _em_proc, NOT_AVAILABLE___
      end

      def __TAKE_ME_via_snapshot_build_and_send_image

        Here_::Build_and_send_image_[ @snapshot_, @kernel_, & @oes_p_ ]
      end

      Result__ = ::Struct.new :reason_proc, :is_available, :shh__

      IS_AVAILABLE___ = true
      MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
      NO_ERRORS_ = nil
      NOTHING_ = nil
      NOT_AVAILABLE___ = false
    end
  end
end
