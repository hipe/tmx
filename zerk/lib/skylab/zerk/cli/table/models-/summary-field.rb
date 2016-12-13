module Skylab::Zerk

  module CLI::Table

    module Models_::SummaryField

      # concepts introduction:
      #
      #   - by this definition a "summary field" is a formal field defined
      #     in the table design whose corresponding output cel is not merely
      #     a direct expression of a value in the input stream, but rather
      #     its expression is somehow "vertically" (and possibly
      #     "horizontally") derived from other data in the page.
      #
      #     (so far the only practical use for these is the
      #     "max-share meter" visualization.)
      #
      #   - it's possible for a summary field to derive from other summary
      #     field values in the row. (#ordinals dictate the order in which
      #     summary fields are calculated.)
      #
      #   - when we say "plain field" in this document, we mean a field that
      #     is not a summary field. be advised that this meaning holds only
      #     in this document. (it has different meaning elsewhere.)
      #
      #   - a summary field's expression can overwrite the would-be output
      #     cel for a corresponding input cel IFF the summary field is
      #     defined to do so. we call such a summary field an "overwriter".
      #
      #   - but ordinarily, a summary field gets its own dedicated cel of
      #     output expression. this means that there is no longer a direct
      #     correspondence between "input offsets" and "field offsets" -
      #     the latter can be a "longer list" than the former. most of
      #     the subject is involved in translating between these two
      #     "offset systems".
      #
      # (the above approaches a beginning of a :[#050.G] "unified language".)

      # some givens for how this data is represented (stored):
      #
      #   - plain fields and summary fields are stored together inline
      #     in one array, with their positions isomorphic to their
      #     positions in the final, rendered output table.
      #
      #   - plain fields and summary fields can occur in any arrangement,
      #     provided that there is at least one plain field.
      #
      #   - a plain field with no metadata is always represented as `nil`.
      #     also, `nil` in such an array always represents such a field.
      #

      # imagine then an as-stored sparse list of defined fields with some
      # summary fields. (in this imaginary case, no summary fields are
      # "overwriters".)
      #
      #     [ f0, nil, f2, sf0, f3, nil, sf1, sf2, f5 ]
      #
      # (although the `nil` spots have "nothing" there, we must imagine them
      # as being the plain fields f1 and f4.)
      #
      # given the axioms given so far, we can induce that the (imaginary)
      # list of plain fields that correspond to input cels looks like this:
      #
      #     [ f0, nil, f2, f3, nil, f5 ]
      #
      # this is simply the as-stored list with the summary fields sliced out.

      # these six plain fields correspond to six assumed elements of
      # each incoming mixed tuple.
      #
      #     [ x0, x1, x2, x3, x4, x5 ]
      #
      # our goal is that the output tuple will look as if the input tuple
      # had been "expanded" by the summary fields like so:
      #
      #     [ x0, x1, se0, x2, x3, x4, se1, se2, x5 ]
      #
      # ("se" for "summary expression".)
      #
      # now, it used to be that we had a complicated way of "expanding" the
      # intermediate array involving something called "expansion packs"
      # (#tombstone-B). presently we accomplish this in a more direct manner:
      #
      #   1. make a new, empty array the size of the final output array:
      #
      #          [ nil, nil, nil, nil, nil, nil, nil, nil, nil ]
      #
      #   2. using an "input-to-output offset map", transfer the input
      #      cels to the output array:
      #
      #          [ 0:0, 1:1, 2:3, 3:4, 4:5, 5:8 ]  # => offset map
      #
      #          [ x0, x1, nil, x2, x3, x4, nil, nil, x5 ]
      #
      #      (we did not explain how we acquired this offset map.)
      #
      #   3. one by one in #ordinal order, derive each summary value:
      #
      #          [ x0, x1, nil, x2, x3, x4, nil, SV2, x5 ]
      #                                           ^
      #          [ x0, x1, SV0, x2, x3, x4, nil, sv2, x5 ]
      #                     ^
      #          [ x0, x1, sv0, x2, x3, x4, SV1, sv2, x5 ]
      #                                      ^
      #      (the particular #ordinal order is an arbitrary given.)

      class << self
        def begin_index
          BuildMasterIndex___.new
        end
      end  # >>

      # ==

      class BuildMasterIndex___

        def initialize

          @expansion_field_count = 0  # never negative
          @_has_fill_fields = false
          @input_to_output_offset_map = []
          @_last_summary_field_index = nil
          @number_of_defined_field = nil
          @_number_of_summary_fields = 0
          @_offsets_of_overwriters = nil
          @_order_array = []
        end

        def receive_NEXT_summary_field fld, d

          _main_thing_via_field_offset d

          if fld.is_in_place_of_input_field
            ( @_offsets_of_overwriters ||= [] ).push d
          else
            @expansion_field_count += 1
          end

          send ORDINAL_VIA___.fetch( fld.summary_field_ordinal_means ), d, fld

          if fld.is_summary_field_fill_field
            @_has_fill_fields = true
          end

          @_number_of_summary_fields += 1
          NIL
        end

        ORDINAL_VIA___ = {
          ordinal_via_literal_integer: :__ordinal_via_literal_integer,
          ordinal_via_next: :__ordinal_via_next,
        }

        def __ordinal_via_next d, _fld
          _occupy_ordinal_slot d, @_number_of_summary_fields
        end

        def __ordinal_via_literal_integer d, fld
          _occupy_ordinal_slot d, fld.summary_field_ordinal_value
        end

        def _occupy_ordinal_slot d, ord_d
          @_order_array[ ord_d ] and fail self._COVER_ME__say_collision( ord_d )  # #todo
          @_order_array[ ord_d ] = d
          NIL
        end

        # -- finish

        def finish defined_fields

          @number_of_defined_fields = defined_fields.length

          _main_thing_via_field_offset @number_of_defined_fields

          # -- validate

          if @_number_of_summary_fields != @_order_array.length
            fail self._COVER_ME__say_missing_ordinals  # #todo
          end
          remove_instance_variable :@_number_of_summary_fields

          # -- any array expander

          if @expansion_field_count.nonzero?
            _array_expander = __build_array_expander
          end

          over_a = remove_instance_variable :@_offsets_of_overwriters

          ord_a = remove_instance_variable :@_order_array

          if remove_instance_variable :@_has_fill_fields

            fill_index = Here_::Models_::FillField.build_index_by do |o|
              o.all_defined_fields = defined_fields
              o.input_to_output_offset_map = @input_to_output_offset_map
              o.order_array = ord_a
            end

            plain_ord_a = fill_index.plain_order_of_operations_offset_array
              # nil if all were fill fields
          else
            plain_ord_a = ord_a.freeze
          end

          if plain_ord_a
            plain_summary_index = PlainSummaryFieldIndex___.new plain_ord_a, defined_fields
          end

          MasterIndex___.define do |o|
            o.array_expander = _array_expander
            o.fill_index = fill_index
            o.offsets_of_overwriters = over_a
            o.plain_index = plain_summary_index
          end
        end

        def __build_array_expander
          ArrayExpander___.new do |o|
            o.expansion_field_count = @expansion_field_count
            o.input_to_output_offset_map = @input_to_output_offset_map
            o.number_of_defined_fields = @number_of_defined_fields
          end
        end

        def _main_thing_via_field_offset d

          _need_this_count = d - @expansion_field_count
          _add_this_many = _need_this_count - @input_to_output_offset_map.length

          this_index = @input_to_output_offset_map.length

          ( this_index ... ( this_index + _add_this_many ) ).each do |dd|
            @input_to_output_offset_map.push dd + @expansion_field_count
          end
        end
      end

      # ==

      class MasterIndex___ < SimpleModel_

        def initialize

          yield self

          @_OCD_method__ = if @array_expander
            if @plain_index
              if @fill_index
                :OCD_yes_yes_yes
              else
                :OCD_yes_yes_no
              end
            else
              :OCD_yes_no_yes
            end
          elsif @plain_index
            if @fill_index
              :OCD_no_yes_yes
            else
              :OCD_no_yes_no
            end
          else
            :OCD_no_no_yes
          end

          freeze
        end

        attr_accessor(
          :array_expander,
          :fill_index,
          :offsets_of_overwriters,
          :plain_index,
        )

        def mutate_page_data page_data, invo
          MutatePageData___.new( page_data, invo, self ).execute
        end

        attr_reader(
          :_OCD_method__,
        )
      end

      # ==

      class MutatePageData___

        def initialize page_data, invo, idx

          @_page_data = page_data
          @__OCD_method_name = idx._OCD_method__

          @_array_expander = idx.array_expander
          @__offsets_of_overwriters = idx.offsets_of_overwriters
          @_plain_index = idx.plain_index
          @_fill_index = idx.fill_index

          # @grow_not_shrink = invo.grow_not_shrink
          @invocation = invo
        end

        def execute

          if @_array_expander
            @_array_expander.__visit_additively_ @_page_data.field_survey_writer
          end
          # else @_ensure_width = __build_ensure_width

          d_a = @__offsets_of_overwriters
          if d_a
            @_page_data.field_survey_writer.clear_these d_a
          end
          d_a = nil

          for_header = @_page_data.HEADER_THING  # see "egads" [#050.1]
          if for_header
            for_header[ @_page_data ]
          end

          if @_plain_index

            @_plain_page_editor = @_plain_index.
              to_tuple_mutator_for_XX @_page_data, @invocation

          end

          if @_fill_index

            @_fill_page_editor = @_fill_index.
              to_tuple_mutator_for_XX @_page_data, @invocation
          end

          ocd_method_name = @__OCD_method_name
          @_page_data.typified_tuples.each do |tuple|
            send ocd_method_name, tuple
          end
          NIL
        end

        # expand / plain / fill

        def OCD_yes_yes_yes tuple
          tuple.replace_array_by do |a|
            a_ = @_array_expander.expanded_array_via a
            @_plain_page_editor.populate_or_overwrite_typified_cels a_
            @_fill_page_editor.populate_or_overwrite_typified_cels a_
            a_
          end
          NIL
        end

        def OCD_yes_yes_no tuple
          tuple.replace_array_by do |a|
            a_ = @_array_expander.expanded_array_via a
            @_plain_page_editor.populate_or_overwrite_typified_cels a_
            a_
          end
          NIL
        end

        def OCD_yes_no_yes tuple
          tuple.replace_array_by do |a|
            a_ = @_array_expander.expanded_array_via a
            @_fill_page_editor.populate_or_overwrite_typified_cels a_
            a_
          end
          NIL
        end

        def OCD_no_yes_yes tuple
          tuple.mutate_array_by do |a|
            # @_ensure_width[ a ]
            @_plain_page_editor.populate_or_overwrite_typified_cels a
            @_fill_page_editor.populate_or_overwrite_typified_cels a
          end
          NIL
        end

        def OCD_no_yes_no tuple
          tuple.mutate_array_by do |a|
            # @_ensure_width[ a ]
            @_plain_page_editor.populate_or_overwrite_typified_cels a
          end
          NIL
        end

        def OCD_no_no_yes tuple
          tuple.mutate_array_by do |a|
            # @_ensure_width[ a ]
            @_fill_page_editor.populate_or_overwrite_typified_cels a
          end
          NIL
        end
      end

      # ==

      class PlainSummaryFieldIndex___

        def initialize ord_a, field_a
          @all_defined_fields = field_a
          @operation_order_array = ord_a
        end

        def to_tuple_mutator_for_XX page_data, invo
          PlainSummaryTupleMutator___.new page_data, invo, self
        end

        attr_reader(
          :all_defined_fields,
          :operation_order_array,
        )
      end

      # ==

      class PlainSummaryTupleMutator___

        def initialize page_data, invo, index

          @__all_defined_fields = index.all_defined_fields
          @__field_survey_writer = page_data.field_survey_writer
          @__operation_order_array = index.operation_order_array
          @__page_data = page_data
          @__invocation = invo
        end

        def populate_or_overwrite_typified_cels mutable_a

          fields = @__all_defined_fields

          fsw = @__field_survey_writer

          row_cont = RowControllerForClient__.new mutable_a, @__invocation

          @__operation_order_array.each do |d|

            fld = fields.fetch d

            _x = fld.summary_field_proc[ row_cont ]

            if fld.is_in_place_of_input_field  # #table-spot-5 repetition
              mutable_a.fetch( d ) || self._SANITY
            else
              mutable_a.fetch( d ) && self._SANITY
            end

            mutable_a[ d ] = fsw.see_then_typified_mixed_via_value_and_index _x, d
          end

          NIL
        end
      end

      # ==

      class RowControllerForClient__  # (similar to #table-spot-4)

        # FOR CLIENT

        def initialize mutable_a, invo
          @__arr = mutable_a
          @__invo = invo
        end

        def row_typified_mixed_at_field_offset_softly d  # 2 defs here, 1x [ze]
          @__arr[ d ]
        end

        def read_observer sym
          @__invo.read_observer_ sym
        end
      end

      # ==

      class ArrayExpander___  # near SimpleModel_

        attr_accessor(
          :expansion_field_count,
          :input_to_output_offset_map,
          :number_of_defined_fields,
        )

        def initialize

          yield self

          @__expansion_packs = Expansion_packs_via__[ self ]

          @__expected_input_tuple_length = @input_to_output_offset_map.length

          freeze
        end

        # -- read

        def __visit_additively_ participant
          _visit :at_index_add_N_items, participant
          NIL
        end

        def _visit m, participant

          @__expansion_packs.each do |ep|
            participant.send m, ep.offset, ep.length
          end
          NIL
        end

        def expanded_array_via aa

          len = aa.length
          a = ::Array.new len + @expansion_field_count

          under = @__expected_input_tuple_length - len
          case 0 <=> under
          when -1

            # when your input tuple is short,
            # truncate your map to how short it is..

            use_map = @input_to_output_offset_map[ 0, len ]

            under.times do
              a.push NOTHING_  # ..
            end

          when 0
            use_map = @input_to_output_offset_map

          when 1
            self._COVER_ME__no_problem_you_just_have_a_wide_input_tuple
          end

          use_map.each_with_index do |d, dd|
            a[ d ] = aa.fetch dd
          end

          a
        end
      end

      # ==

      Expansion_packs_via__ = -> args do

        # a list of "expansion packs" is something like the photo-negative
        # of the input-to-output offset map: whereas the map maps input
        # offsets to output offsets, an expansion pack is a representation
        # of fields in the output that are not in the input.
        #
        # each "pack" is merely an *input* offset and a nonzero positive
        # integer for "length" number of empty cels to add to a (perhaps
        # imaginary) input array being mutated for output.
        #
        # imagine a crazy, real-world construction technique where you can
        # *insert floors* into a building. if you were to say:
        #
        #   - at the third floor, insert two floors
        #   - then at the fifth floor, insert one floor
        #
        # the instructions are ambiguous and confusing: when we say
        # "fifth floor", do we mean the old fifth floor or the new fifth
        # floor? to avoid this ambiguity, we put such instructions in an
        # order that avoids the problem:
        #
        #   - at the fifth floor, insert one floor
        #   - then at the third floor, insert two floors
        #
        # by ordering the operations from top to bottom along the building,
        # any given step can have no impact the "offsets" of any next step
        # to come after it.
        #
        # we likewise follow this ordering here for this same reason that it
        # is more poka-yoke. it is crucial that clients of this data
        # understand that A) these "packs" are in "operation order" and B)
        # that the offsets of each pack are in input offsets, not field
        # offsets.
        #
        # incidentally this whole technique was deemed too confusing at
        # one point and we tried to do away with it; but it turned out that
        # it was still useful in a few places. but during that rewrite
        # this assembling of "expansion packs" moved from the main indexing
        # node here to the subject function. this newer way seems better
        # because it isolates this now more specialized technique to its
        # narrower scope, but it feels more dodgy here too .. #tombstone-A
        # -

          expansion_packs = []

          a = args.input_to_output_offset_map
          prev_d = args.number_of_defined_fields
          args = nil ; dist = nil ; dd = nil

          st = Common_::Stream.via_range( a.length - 1 .. 0 )

          is_a_jump = -> do
            this_d = a.fetch dd
            dist = prev_d - this_d
            prev_d = this_d
            1 != dist
          end

          begin
            dd = st.gets
            dd || break
            if is_a_jump[]
              expansion_packs.push ExpansionPack__.new( dd + 1, dist - 1 )
            end
            redo
          end while above

          if prev_d.nonzero?

            # if the final field offset seen does not correspond with the
            # leftmost input offset (0), then you have an expansion anchored
            # at the beginning

            expansion_packs.push ExpansionPack__.new( 0, prev_d )
          end

          expansion_packs
        # -
      end

      # ==

      ExpansionPack__ = ::Struct.new :offset, :length

      # ==
    end
  end
end
# #tombsone-A build "expansion packs" during main algorithm
# #born during unification to replace legacy architecture for formulas
