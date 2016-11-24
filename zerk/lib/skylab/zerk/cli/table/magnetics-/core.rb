module Skylab::Zerk

  module CLI::Table

    module Magnetics_

      Autoloader_[ self ]

      # ==

      class LineStream_via_MixedTupleStream_and_Design < Common_::Actor::Dyadic

        def initialize mt_st, de
          @design = de
          @mixed_tuple_stream = mt_st
        end

        def execute
          @_state = :__any_first_line_ever
          Common_.stream do
            send @_state
          end
        end

        # two things to remember here throughout: 1) you're always rendering
        # a line until you close. 2) always think about when to change @_state.

        def __any_first_line_ever

          remove_instance_variable :@_state

          @_invocation = Here_::Models_::Invocation.new(
            remove_instance_variable( :@mixed_tuple_stream ),
            @design,
          )

          @_page_scanner = @_invocation.page_scanner

          if @_page_scanner.no_unparsed_exists
            NOTHING_  # hi.
          else
            @_notes = @_invocation.notes
            @_page = @_page_scanner.gets_one
            __on_first_page_ever
          end
        end

        def __on_first_page_ever

          if __do_display_header_row
            __make_a_note_of_the_widths_of_each_any_field_label
            _reinit_line_renderer_via_page
            __header_row
          else
            _on_page
          end
        end

        def __do_display_header_row
          @_invocation.do_display_header_row
        end

        def __make_a_note_of_the_widths_of_each_any_field_label

          @design.fields.each_with_index do |fld, d|
            label = fld.label
            label || next
            @_notes.for_field( d ).widest_width_ever = label.length
          end
          NIL
        end

        def __header_row

          fields = @design.fields  # at least one with a label somewhere

          _d = @_notes.the_most_number_of_columns_ever_seen

          _st = Common_::Stream.via_times _d do |d|

            fld = fields.fetch d  # ..

              label = fld.label

            Tabular_::Models::Typified::Mixed.new :string, ( label || EMPTY_S_ )
          end

          @_state = :_on_line_renderer_and_page

          @_line_via_typified_mixed_stream[ _st ]
        end

        def _on_page
          _reinit_line_renderer_via_page
          _on_line_renderer_and_page
        end

        def _on_line_renderer_and_page
          _page = remove_instance_variable :@_page  # (or not)
          @_typified_tuple_stream = _page.to_typified_tuple_stream
          @_state = :__another_line_via_typified_tuples
          send @_state
        end

        def __another_line_via_typified_tuples
          typi_tuple = @_typified_tuple_stream.gets
          if typi_tuple
            _typi_mixed_st = typi_tuple.to_typified_mixed_stream
            @_line_via_typified_mixed_stream[ _typi_mixed_st ]
          else
            __at_end_of_page
          end
        end

        def __at_end_of_page

          # (one day maybe aggregate statistical information of the whole
          # page e.g for totals)

          # (sanity cleanup for now)
          remove_instance_variable :@_line_via_typified_mixed_stream
          remove_instance_variable :@_state
          remove_instance_variable :@_typified_tuple_stream

          if @_page_scanner.no_unparsed_exists
            # (one day maybe summary row hooks)
            NOTHING_
          else
            @_page = @_page_scanner.gets_one
            _on_page
          end
        end

        def _reinit_line_renderer_via_page

          @_notes.see_this_number_of_columns @_page.number_of_fields

            @_line_via_typified_mixed_stream =
          LineRenderer_via_Page_and_Invocation___.call(
            @_page, @_invocation,
          )
          NIL
        end
      end

      # ==

      LineRenderer_via_Page_and_Invocation___ = -> page, invo do

        number_of_fields = invo.notes.the_most_number_of_columns_ever_seen

        field_surveys = page.field_surveys

        cel_renderers = number_of_fields.times.map do |d|

          Magnetics_::TypifiedMixedRenderer_via_FieldSurvey.new(
            d,
            field_surveys.fetch( d ),  # ..
            invo,
          ).execute
        end

        this_many_times = number_of_fields.zero? ? 0 : number_of_fields - 1

        design = invo.design

        -> typi_st do

          buffer = "#{ design.left_separator }"

          d = -1
          write_cel = -> do
            d += 1
            use_typi = typi_st.gets
            # ..
            buffer << cel_renderers.fetch( d )[ use_typi ]
            NIL
          end

          write_cel[]

          this_many_times.times do
            buffer << design.inner_separator
            write_cel[]
          end

          buffer << design.right_separator
        end
      end

    if false  # keep while #open [#tab-003]

  FLOAT_DETAIL_RX__ = /\A(-?\d+)((?:\.\d+)?)\z/  # used 2x

  module Types__

    mod = Home_::CLI_Support::Styling
    unstyle = mod::Unstyle

    parse_styles = mod::Parse_styles
    unparse_styles = mod::Unparse_style_sexp

    hackable_a = [ :style, :string, :style ]

    common = -> fld do
      fmt = "%#{ '-' if fld.is_align_left }#{ fld.max_width :full }s"
      -> str do
        sexp = parse_styles[ str ]  # are you ready for ridiculous? if the
        if sexp  # string was styled, remove the styling, apply the width
          if hackable_a == sexp.map(& :first )  # resizing, and re-apply styling
            sexp[1][1] = fmt % sexp[1][1]
            unparse_styles[ sexp ]
          else
            unstyle[ str ]  # glhf
          end
        else
          fmt % str
        end
      end
    end

    float_detail_rx = FLOAT_DETAIL_RX__

    float = -> fld do
      int_max = fld.max_width :int_part
      flt_max = fld.max_width :frac_prt
      fmt = "%#{ int_max }s%-#{ flt_max }s"
      fallback = common[ fld ]
      -> str do
        md = float_detail_rx.match str
        if md
          fmt % md.captures
        else
          fallback[ str ]
        end
      end
    end

    STRING = Field_Type__.new :string, rx: //, align: :left, render: common


    BLANK = Field_Type__.new :blank, ancestor: :string,
                                   rx: /\A[[:space:]]*\z/, render: common

    FLOAT = Field_Type__.new :float, ancestor: :string,
                                   rx: /\A-?\d+(?:\.\d+)?\z/, render: float

    INTEGER = Field_Type__.new :integer, ancestor: :float, align: :right,
                                       rx: /\A-?\d+\z/, render: common

  end

  class Type_Stats___

    def has_information
      0 < @num_non_nil_seen
    end

    attr_reader(
      :index,
      :max_h,
      :type_h,
    )

    # --*--

    blank_rx = Types__::BLANK.rx

    float_detail_rx = FLOAT_DETAIL_RX__

    start_type = Types__::INTEGER

    unstyle = Home_::CLI_Support::Styling::Unstyle

    define_method :see do |cel_x|  # `cel_x` must be ::String or nil
      if ! cel_x.nil?
        ::String === cel_x or raise ::ArgumentError, "table cels *must* #{
          }be nil or string for reasons - #{ cel_x.class }"
        @num_non_nil_seen += 1
        raw = unstyle[ cel_x ]
        @max_h[:full] = raw.length if raw.length > @max_h[:full]
        if blank_rx =~ raw
          @type_h[:blank] += 1
        else
          type = start_type
          type = type.ancestor until type.match? raw  # ballzy
          @type_h[ type.symbol ] += 1
          if :float == type.symbol
            md = float_detail_rx.match raw
            @max_h[:int_part] = md[1].length if md[1].length > @max_h[:int_part]
            @max_h[:frac_prt] = md[2].length if md[2].length > @max_h[:frac_prt]
          end
        end
      end
    end
  end
    end   # if false
      # ==
    end
  end
end
# #tombstone: was once [#001.C]
# #tombstone: one last external use of :employ_DSL_for_digraph_emitter
# #tombstone: at full rewrite, early field class, "census" class, "type stats" class
