# frozen_string_literal: true

module Skylab::Arc::TestSupport

  class Git_Config_Magnetics::Unit_of_Work_Stream_via_Spoof

    class << self
      def call_by ** hh
        new( ** hh ).execute
      end
      private :new
    end  # >>

    # -

      def initialize(
        number_of_components: nil,
        associated_component_offsets: nil,
        reallocation_schematic: nil,
        lib: nil
      )
        @associated_component_offsets = associated_component_offsets
        @reallocation_schematic = reallocation_schematic
        @number_of_components = number_of_components
        @lib = lib
      end

      def execute

        __init_associated_schema_and_ugly_table
        _as = remove_instance_variable :@__OUT_associated_schema
        _ay = remove_instance_variable :@__OUT_associations_YUCK

        _200 = @lib.product_of_magnetic_200_SPOOFED_HACKISHLY_(

          associations_YUCK: -> o do
            _ay.each do |three|
              o[ * three ]
            end
          end,

          associated_schema: _as,
        )

        # (note we build them in order, but the below doesn't use the above)

        _300 = @lib.product_of_magnetic_300_SPOOFED_( * @reallocation_schematic )

        _400 = @lib.call_magnetic_400_ _300

        [ @number_of_components, nil, _200, _300, _400 ]
      end

      def __init_associated_schema_and_ugly_table

        # BACK derive the associated schema from the reallocation schematic!

        associations_yuck = []
        associated_schema = []

        # -- local variables shared between functions

        current_associated_schema_cluster = nil

        current_cluster_offset = -1
        current_offset_into_association_cluster = nil
        these = @associated_component_offsets

        # -- functions

        receive_static_associated = -> associated_offset do

          current_offset_into_association_cluster += 1  # yikes 1/2

          _component_offset = these.fetch associated_offset

          associations_yuck.push [
            _component_offset,
            current_cluster_offset,
            current_offset_into_association_cluster,
          ]

          current_associated_schema_cluster.push associated_offset
        end

        receive_non_associated = -> number_of_fellows do
          number_of_fellows.times do

            current_offset_into_association_cluster += 1  # yikes 2/2
            current_associated_schema_cluster.push nil
          end
        end

        close_cluster = -> do
          current_associated_schema_cluster.freeze
          associated_schema.push current_associated_schema_cluster
          current_associated_schema_cluster = nil
        end

        on_new_cluster_common = -> do
          current_associated_schema_cluster = []
          current_cluster_offset += 1
          current_offset_into_association_cluster = -1
        end

        on_new_cluster_subsequently = -> do
          close_cluster[]
          on_new_cluster_common[]
        end

        on_new_cluster = -> do
          on_new_cluster = on_new_cluster_subsequently
          on_new_cluster_common[]
        end

        # -- work

        @reallocation_schematic.each do |cluster|
          on_new_cluster[]
          cluster.each do |segment|
            2 == segment.length || no

            case segment.fetch 0
            when :_static_associated__associated_offset_
              receive_static_associated[ segment.fetch 1 ]

            when :_non_associated__number_of_fellows_
              receive_non_associated[ segment.fetch 1 ]

            else ; no
            end
          end
        end

        close_cluster[]

        @__OUT_associated_schema = associated_schema.freeze
        @__OUT_associations_YUCK = associations_yuck.freeze
        NIL
      end

    # -

    # -

    # ==

    VISITING_this_guy = -> uow_st, exp_component_num do

      # "flat map" the stream of units of work into a stream of offsets

      # this is #[#ts-038.3] one of these. (we might DRY it later, but food
      # for thought: look at all the ad-hoc metadata we are stuffing into
      # the traversal. that would need to be accomodated.)

      last_uow = nil
      last_uow_offset = -1
      big_st = uow_st.flat_map_by do |uow|
        last_uow_offset += 1
        last_uow = uow
        _d_a = uow.fetch 1
        _d_a.first.odd?  # typecheck that it's int for now. this is about to change very soon
        Home_::Stream_[ _d_a ]
      end

      where = -> do
        " at UoW at offset #{ last_uow_offset } ([INSERT CATEGORY SYMOBL HERE])"
      end

      current_expected_offeset = 0

      until current_expected_offeset == exp_component_num
        act_d = big_st.gets
        if ! act_d
          reached_end_early = true
          break
        end
        if act_d != current_expected_offeset
          fail "expecteded #{ current_expected_offeset } had #{ act_d }#{ where[] }"
        end
        current_expected_offeset += 1
      end

      if reached_end_early
        fail "reached end of stream when expecting #{ current_expected_offeset }#{ where[] }"
      else
        act_d = big_st.gets
        if act_d
          fail "expected no more offsets but had #{ act_d }#{ where[] }"
        end
      end
    end

    # ==
    # ==
  end
end
# born.
