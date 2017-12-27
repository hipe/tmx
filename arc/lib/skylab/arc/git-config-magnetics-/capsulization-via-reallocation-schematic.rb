module Skylab::Arc

  class GitConfigMagnetics_::Capsulization_via_ReallocationSchematic <
      Common_::MagneticBySimpleModel

    # exactly capsulization [#024.N]
    #
    # mainly, state machine yadda

    # -
      attr_writer(
        :reallocation_schematic,
      )

      def execute

        __init_capsule_clusterization

        @reallocation_schematic.each_with_index do |cluster, d|

          @_current_cluster_offset = d
          @_current_cluster = cluster
          __on_begin_cluster

          @_current_cluster.each_with_index do |segment, dd|

            @_current_cluster_element_offset = dd
            send THESE___.fetch segment.segment_category_symbol
          end

          __on_end_cluster
        end
        remove_instance_variable :@_current_cluster_element_offset
        remove_instance_variable :@_current_cluster_offset
        remove_instance_variable :@_current_cluster
        __close_state_machine
        remove_instance_variable :@reallocation_schematic  # the argument. we could keep it here too
        freeze
      end

      THESE___ = {
        _static_associated__associated_offset_: :__on_static_associated,
        _non_associated__number_of_fellows_: :__on_unassociated,
      }

      # -- D. the interesting parts of the state transitions

      def __touch_in_progress_capsule

        current_capsule_offset = @capsules.length - 1

        in_progress_capsule = @capsules.fetch current_capsule_offset

        _len = in_progress_capsule.number_of_cluster_locators

        @_current_capsule_cluster[ @_current_cluster_element_offset ] =
          CapsuleReference__.new(
            current_capsule_offset,
            _len,
          )

        in_progress_capsule.__push_ _build_current_locator

        NIL
      end

      def _close_capsule
        @capsules.last.freeze
        NIL
      end

      def _open_capsule

        @_current_capsule_cluster[ @_current_cluster_element_offset ] =
          CapsuleReference__.new( @capsules.length, 0 ).freeze

        @capsules.push Capsule___.new _build_current_locator

        NIL
      end

      # -- C. simple things that drive the state machine

      def __on_unassociated
        _receive_state_transition :unassociated
        NIL
      end

      def __on_static_associated
        _receive_state_transition :associated
        NIL
      end

      def __on_end_cluster
        _ccc = remove_instance_variable :@_current_capsule_cluster
        @capsule_clusterization[ @_current_cluster_offset ] = _ccc.freeze
        _receive_state_transition :end_cluster
        NIL
      end

      def __on_begin_cluster
        @_current_capsule_cluster = ::Array.new @_current_cluster.length
        _receive_state_transition :begin_cluster
        NIL
      end

      def __init_capsule_clusterization
        _set_state :start_slash_gap
        @capsule_clusterization = ::Array.new @reallocation_schematic.length  # #testpoint (ivar name)
        @capsules = []
        NIL
      end

      def _build_current_locator
        ClusterLocator___.new(
          @_current_cluster_offset,
          @_current_cluster_element_offset,
        )
      end

      # -- B. experimental roll-our-own state machine

      def _receive_state_transition sym
        these = @_state_hash[ sym ]
        if ! these
          # (deveopment aid)
          fail __say_state_transition sym
        end
        send these.first, * these[1..-1]  # ..
        NIL
      end

      def __say_state_transition sym
        "there is no transition out of '#{ @_state_symbol }' state with #{
          }'#{ sym }'. (there is (#{ @_state_hash.keys * ', ' }))"
      end

      def do m, * then_x
        if then_x.length.nonzero?
          :then == then_x.first || fail
          send m
          _set_state( * then_x[ 1..-1 ] )
        else
          send m
        end
      end

      def transition_to state_sym
        _set_state state_sym  # hi.
        NIL
      end

      def _set_state sym
        @_state_hash = Custom_state_machine___[].fetch sym
        @_state_symbol = sym ; nil
      end

      def stay_in_this_same_state
        NOTHING_
      end

      def __close_state_machine
        remove_instance_variable :@_state_hash
        remove_instance_variable :@_state_symbol ; nil
      end

      # -- A.

      attr_reader(
        :capsule_clusterization,
        :capsules,
      )

    # -

    Custom_state_machine___ = Lazy_.call do

      # exactly [#024:figure-1].
      #
      # (for now, our requirements don't seem to justify bringing out
      # [#ba-044] the big guns of a dedicated state machine facility.)

      state = {}

      state[ :start_slash_gap ] = {
        begin_cluster: [ :transition_to, :head_listening ],
        end_everything: [ :do, :__END_EVERYTHING ],
      }

      state[ :head_listening ] = {
        associated: [ :stay_in_this_same_state ],
        unassociated: [ :do, :_open_capsule, :then, :begun ],
        end_cluster: [ :transition_to, :start_slash_gap ],
      }

      state[ :begun ] = {
        end_cluster: [ :transition_to, :gap_while_in_progress ],
        associated: [ :do, :_close_capsule, :then, :mid_listening ],
      }

      state[ :gap_while_in_progress ] = {
        begin_cluster: [ :transition_to, :begin_while_in_progress ],
        end_everything: [ :do, :__CLOSE_AND_DONE ],
      }

      state[ :begin_while_in_progress ] = {

        unassociated: [ :do, :__touch_in_progress_capsule, :then, :begun ],
        associated: [ :do, :_close_capsule, :then, :mid_listening ],
      }

      state[ :mid_listening ] = {
        associated: [ :stay_in_this_same_state ],
        end_cluster: [ :transition_to, :start_slash_gap ],
        unassociated: [ :do, :_open_capsule, :then, :begun ],
      }

      state.freeze
    end

    # ==

    class ClusterLocator___

      def initialize d, dd
        @cluster_offset = d
        @cluster_element_offset = dd
        freeze
      end

      def __is_this_special_first_thing_
        @cluster_offset.zero? &&
          @cluster_element_offset.zero?
      end

      attr_reader(
        :cluster_offset,
        :cluster_element_offset,
      )
    end

    class CapsuleReference__

      def initialize d, dd
        @capsule_offset = d
        @offset_into_capsule = dd
        freeze
      end

      attr_reader(
        :capsule_offset,
        :offset_into_capsule,
      )
    end

    class Capsule___

      def initialize initial_loc
        @cluster_locators = [ initial_loc ]
      end

      def __push_ x
        @cluster_locators.push x
      end

      def first_cluster_locator
        @cluster_locators.first
      end

      def number_of_cluster_locators
        @cluster_locators.length
      end

      attr_reader(
        :cluster_locators,
      )
    end

    # ==
    # ==
  end
end
# #born (after ~6 months in stash)
