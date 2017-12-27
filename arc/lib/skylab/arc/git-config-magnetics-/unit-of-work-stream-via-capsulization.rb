module Skylab::Arc

  class GitConfigMagnetics_::UnitOfWorkStream_via_Capsulization

    # [#here.O] capsule expanding and contracting, units of work

    # broadly these are the kinds of steps (units of work):
    #
    #   - pending headmost moves before a head-anchored static
    #   - flush one or more static segments
    #   - capsule easy
    #   - capsule hard
    #   - ??

    class << self
      def call_by ** h
        new( ** h ).execute
      end
      private :new
    end  # >>

    # -

      def initialize(
        capsulization: nil,
        one_two_three: nil,
        number_of_components: nil
      )

        number_of_components || ::Kernel._I_NEED_THIS
        _100_NOT_USED, pluralton_components_index, reallocation_schematic = one_two_three

        @associated_components = pluralton_components_index.associated_locators
        # @ASSOCIATED_CLUSTERS = pluralton_components_index.associated_clusters

        # @CAPSULE_CLUSTERIZATION = capsulization.capsule_clusterization

        @capsule_scanner = Scanner_[ capsulization.capsules ]
        @cluster_scanner = Scanner_[ reallocation_schematic ]

        @_pending_component_offset = 0  # per #theme-2, always 0
        @number_of_components = number_of_components
      end

      def execute
        @_gets = :__the_very_beginning
        Common_.stream do
          send @_gets
        end
      end

      def __the_very_beginning
        _at_next_cluster
        if _cluster_segment_is_static
          if __there_are_pending_moves_before_this_cluster
            __step_for_headmost_moves_then_static
          else
            _static_then_whatever
          end
        else
          ::Kernel._OKAY
        end
      end

      def __there_are_pending_moves_before_this_cluster
        # assume at head of cluster and segment is static associated.

        _offset = _static_component_offset

        case @_pending_component_offset <=> _offset
        when -1 ; true
        when  0 ; false
        else    ; never
        end
      end

      #
      # step-flushers
      #

      def _static_then_whatever

        # assume current cluster segment is static

        d_a = []
        begin

          co = _static_component_offset

          while @_pending_component_offset < co
            # #coverpoint3.3 - for now, components to add get spliced in to here
            d_a.push @_pending_component_offset
            @_pending_component_offset += 1
          end

          d_a.push co
          @_pending_component_offset = co + 1

          _advance_one_cluster_segment
          if _no_more_cluster_segments
            did_reach_end_of_cluster = true
            break
          end
        end while _cluster_segment_is_static

        if did_reach_end_of_cluster
          _at_end_of_cluster
        else
          ::Kernel._OKAY__must_be_capsule__
        end

        [ :_STATIC_PASSTHRU_AND_MAYBE_MORE_, d_a.freeze ]
      end

      def __step_for_headmost_moves_then_static
        # assume at head of cluster and segment is static associated. #coverpoint3.1

        _next_do :_static_then_whatever
        _r = _advance_component_offset_to _static_component_offset
        [ :_HEADMOST_MOVE_COMPONENTS_, _r.to_a.freeze ]
      end

      def __flush_tailmost_components  # set next step. #coverpoint3.2
        _r = _advance_component_offset_to @number_of_components
        _close
        [ :_TAILMOST_MOVE_COMPONENTS_, _r.to_a.freeze ]
      end

      #
      # higher level mutate
      #

      def _at_end_of_cluster  # determine next step

        remove_instance_variable :@_cluseg_scanner
        _advance_one_cluster
        if _no_more_clusters
          __at_end_of_clusters
        else
          ::Kernel._OKAY__advance_to_next_custer_and_call_at_next_cluster
        end
      end

      def __at_end_of_clusters  # determine next step

        remove_instance_variable :@cluster_scanner

        case @_pending_component_offset <=> @number_of_components
        when -1 ;
          _next_do :__flush_tailmost_components
        when  0 ; _close ; nil
        else no
        end
      end

      #
      # middle-level mutate (advancers)
      #

      def _advance_one_cluster_segment
        @_cluseg_scanner.advance_one
      end

      def _advance_one_cluster
        @cluster_scanner.advance_one
      end

      #
      # lower-level mutate
      #

      def _at_next_cluster
        _cluster = @cluster_scanner.head_as_is
        @_cluseg_scanner = Scanner_[ _cluster ] ; nil
      end

      def _advance_component_offset_to d
        r = @_pending_component_offset ... d
        @_pending_component_offset = d
        r
      end

      def _close
        _next_do :_NOTHING ; freeze ; nil
      end

      def _next_do m
        @_gets = m ; nil
      end

      #
      # read
      #

      def _static_component_offset
        _ao = _cluster_segment.associated_offset
        _assoc = @associated_components.fetch _ao
        _assoc.COMPONENT_OFFSET
      end

      def _cluster_segment_is_static
        _cluster_segment.is_static_associated
      end

      def _cluster_segment
        @_cluseg_scanner.head_as_is
      end

      def _no_more_cluster_segments
        @_cluseg_scanner.no_unparsed_exists
      end

      def _no_more_clusters
        @cluster_scanner.no_unparsed_exists
      end

      def _NOTHING
        NOTHING_
      end
    # -

    # ==
    # ==
  end
end
# #born.
