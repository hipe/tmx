module Skylab::Zerk

  module CLI::Table

    class << self
      def line_stream_via_mixed_tuple_stream st
        default_design.line_stream_via_mixed_tuple_stream st
      end

      def default_design
        Default_design___[]
      end
    end  # >>

    Default_design___ = Lazy_.call do

      Design.define do |defn|

        defn.separator_glyphs '| ', ' | ', ' |'
      end
    end

    class Design_DSL__

      def initialize de
        @_ = de
      end

      def add_field_observer * x_a, & p
        Require_tabular__[]
        @_.__receive_field_observer_ Tabular_::Models::FieldObserver.new p, x_a
      end

      def add_summary_row & p
        _sr = Here_::Models_::SummaryRow::Definition.new p
        @_.__receive_summary_row_ _sr
      end

      def redefine_field d, * x_a, & p
        @_.__redefine_field_ d, p, x_a
      end

      def add_field * x_a, & p
        @_.__add_field p, x_a
      end

      def separator_glyphs lef, inn, rig
        @_.left_separator = lef
        @_.inner_separator = inn
        @_.right_separator = rig ; nil
      end

      def page_size d
        @_.page_size = d
      end
    end

    class Design

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize

        @_accept_field = :__accept_first_field
        @field_observers = nil
        @_has_defined_fields = false
        @inner_separator = SPACE_
        @left_separator = nil
        @page_size = 50
        @right_separator = nil
        @summary_rows = nil

        yield Design_DSL__.new self
        finish
      end

      def redefine
        otr = dup
        yield Design_DSL__.new otr
        otr.finish
      end

      def initialize_copy _

        if @_has_defined_fields
          @_defined_field_offset_via_input_offset =
            @_defined_field_offset_via_input_offset.dup
          @_defined_fields = @_defined_fields.dup
        end

        if @summary_rows
          self._COVER_ME
        end

        NOTHING_  # hi.
      end

      # -- write

      def __receive_field_observer_ fo
        ( @field_observers ||=
            Tabular_::Models::FieldObserver::Collection.new ) << fo
        NIL
      end

      def __receive_summary_row_ srd
        ( @summary_rows ||=
           Here_::Models_::SummaryRow::DefinitionCollection.new ) << srd
      end

      def __redefine_field_ d, p, x_a
        @_defined_fields[ d ] = @_defined_fields.fetch( d ).redefine__ p, x_a
        NIL
      end

      def __add_field p, x_a
        send @_accept_field, p, x_a
      end

      def __accept_first_field p, x_a
        @_has_defined_fields = true
        @_defined_field_offset_via_input_offset = []
        @_defined_fields = []
        @_accept_field = :__accept_subsequent_field
        send @_accept_field, p, x_a
      end

      def __accept_subsequent_field p, x_a

        if x_a.length.zero?
          if p
            self._COVER_ME_argument_error_cant_have_proc_without_arguments  # #todo
          end

          treat_as_plain_field = true
        else

          fld = Here_::Models_::Field.new p, x_a

          if fld.is_summary_field
            treat_as_plain_field = fld.is_in_place_of_input_field
          else
            treat_as_plain_field = true
          end
        end

        # a field with no metadata is only ever represented by `nil`, and
        # `nil` (in this context) only ever represents a field with no
        # metadata. :[#050.D]

        if treat_as_plain_field
          @_defined_field_offset_via_input_offset.push @_defined_fields.length
        end

        @_defined_fields.push fld
        NIL
      end

      attr_accessor(
        :field_observers,
        :inner_separator,
        :left_separator,
        :page_size,
        :right_separator,
        :summary_rows,
      )

      def finish

        # the below "index"-like calculations are done at the end and not
        # on field add (for example) in part because they have to work
        # across the dup-mutate boundary - a redesign could remove/alter fields

        if @_has_defined_fields

          defined_fields = @_defined_fields
          len = defined_fields.length
          d = -1

          # ~ summary fields

          summary_fields = nil

          # ~ header row

          one_has_label = false

          # ~ alignment

          left = ::Array.new len
          right = left.dup
          align = {
            left: -> { left[d] = true },
            right: -> { right[d] = true },
          }

          begin
            d += 1
            len == d && break
            fld = defined_fields.fetch d
            fld || redo

            # ~ summary fields

            if fld.is_summary_field
              summary_fields ||= Here_::Models_::SummaryField::Index.begin
              summary_fields.receive_NEXT_summary_field fld, d
            end

            # ~ header row

            if ! one_has_label && fld.label
              one_has_label = true
            end

            # ~ alignment

            sym = fld.align
            if sym
              align.fetch( sym ).call
            end
            redo
          end while above

          if summary_fields
            summary_fields = summary_fields.finish
          end

        else
          left = MONADIC_EMPTINESS_
          right = MONADIC_EMPTINESS_
        end

        @__has_at_least_one_field_label = one_has_label
        @__left_explicitly = left
        @__right_explicitly = right
        @__summary_fields_index = summary_fields

        @left_separator ||= EMPTY_S_  # so we don't have to check for
        @right_separator ||= EMPTY_S_  # nils where it is used

        freeze
      end

      def freeze

        if @_has_defined_fields
          @_defined_field_offset_via_input_offset.freeze
          @_defined_fields.freeze
        end

        @field_observers and @field_observers.freeze
        @summary_rows and @summary_rows.freeze
        super
      end

      # -- use

      def line_stream_via_mixed_tuple_stream st

        Require_tabular__[]

        Here_::Magnetics_::LineStream_via_MixedTupleStream_and_Design[ st, self ]
      end

      # -- read

      def field_is_aligned_left_explicitly d
        @__left_explicitly[ d ]
      end

      def field_is_aligned_right_explicitly d
        @__right_explicitly[ d ]
      end

      def for_field d

        # (allow that field-specifics possibly haven't been defined at all;
        # but if they have, enforce the assumption that *something* (maybe
        # nil) is at that offset.)

        if @_has_defined_fields
          @_defined_fields.fetch d
        end
      end

      # ~ (emphasize the single points of contact (R [W]) for refactorability)

      def summary_fields_index__
        @__summary_fields_index
      end

      def has_at_least_one_field_label__
        @__has_at_least_one_field_label
      end

      def anticipated_final_number_of_columns_per_defined_fields__  # assume.
        @_defined_fields.length
      end

      def defined_field_for_input_offset__ d

        # this does not assume that there are any defined fields, but if
        # there are, this enforces the assumption (for now) that the width
        # of any input mixed tuple will not exceed that of the number of
        # defined, non-summary fields. but per [#050.D], the `nil` value
        # represents one kind of "defined field" so if that's the result
        # here, that's what it means.

        d || self._SANITY  # #todo

        if @_has_defined_fields
          @_defined_fields.fetch @_defined_field_offset_via_input_offset.fetch d
        end
      end

      def all_defined_fields  # assume.
        @_defined_fields
      end

      def has_defined_fields__
        @_has_defined_fields
      end
    end

    # ==

    Require_tabular__ = Lazy_.call do
      Tabular_ = Home_.lib_.tabular ; nil
    end

    # ==

    Here_ = self
  end
end
# #tomstone: used to be the "structured" table lib [#xxx.D]. full rewrite. had
#   early "metrics" (statistics) structure, content matrix, visitor pattern, summary
