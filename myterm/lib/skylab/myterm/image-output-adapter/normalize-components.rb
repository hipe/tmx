module Skylab::MyTerm

  module Image_Output_Adapter

    class Normalize_Components

      self._NOTE  # this was just cut-and-paste here. half is reference

      # see [#004]:principal-algorithm-1 - when images are made

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

        st = ACS_::Reflection::Qualified_knownness_stream_via_ACS[ self ]

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

      def __via_snapshot_build_and_send_image

        Here_::Build_and_send_image_[ @snapshot_, @kernel_, & @oes_p_ ]
      end
    end
  end
end
