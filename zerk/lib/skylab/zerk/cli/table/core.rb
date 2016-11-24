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

      Design___.define do |defn|

        defn.separator_glyphs '|  ', ' |  ', '  |'
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

      def redefine_field d, * x_a
        @_.__redefine_field_ d, x_a
      end

      def add_field * x_a
        @_.__accept_field_ Here_::Models_::Field.new x_a
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

    class Design___  # (you can expose if wanted)

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize

        @_accept_field = :__accept_first_field
        @field_observers = nil
        @has_fields = false
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
        if @has_fields
          @fields = @fields.dup
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

      def __redefine_field_ d, x_a
        @fields[ d ] = @fields.fetch( d ).redefine__ x_a
        NIL
      end

      def __accept_field_ fld
        send @_accept_field, fld
      end

      def __accept_first_field fld
        @has_fields = true
        @_accept_field = :__accept_subsequent_field
        @fields = []
        send @_accept_field, fld
      end

      def __accept_subsequent_field fld
        @fields.push fld ; nil
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

        if @has_fields

          one_has_label = nil
          len = @fields.length
          left = ::Array.new len
          right = left.dup
          d = len
          align = {
            left: -> { left[d] = true },
            right: -> { right[d] = true },
            nil => EMPTY_P_,
          }
          begin
            d -= 1
            fld = @fields.fetch d
            align.fetch( fld.align ).call
            if fld.label
              one_has_label = true
            end
          end until d.zero?
        else
          left = MONADIC_EMPTINESS_
          right = MONADIC_EMPTINESS_
        end

        @has_at_least_one_field_label = one_has_label
        @__left_explicitly = left
        @__right_explicitly = right

        freeze
      end

      def freeze
        @field_observers and @field_observers.freeze
        @has_fields and @fields.freeze
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

      def fields
        @fields  # for warnings
      end

      attr_reader(
        :has_at_least_one_field_label,
        :has_fields,
      )
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
