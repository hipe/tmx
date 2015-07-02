module Skylab::Brazen

  # -> 2

      class CLI::Expression_Frames::Table::Structured  # see [#096.D]

        # ~ defining a table

        def initialize

          @_bx = Callback_::Box.new

          @_do_show_header_row = true
          @expression_width = nil
          @_left_glyph = LEFT_GLYPH___
          @_right_glyph = RIGHT_GLYPH___
          @_sep_glyph = SEP_GLYPH___
        end

        LEFT_GLYPH___ = '|  '
        RIGHT_GLYPH___ = ' |'
        SEP_GLYPH___ = ' |  '

        def edit_table * x_a

          st = Callback_::Polymorphic_Stream.via_array x_a

          fld_st = IG__.simple_stream_of_items_via_polymorpic_stream st

          @polymorphic_upstream_ = st

          begin

            did = false

            begin

              fld = fld_st.gets
              fld or break
              did = true
              __accept_field fld
              redo
            end while nil

            begin

              if st.no_unparsed_exists
                break
              end

              m = :"#{ st.current_token }="
              if respond_to? m
                st.advance_one
                _kp = send m
                _kp or raise ::ArgumentError  # meh
                did = true
                redo
              end
              break
            end while nil

            if did
              if st.unparsed_exists
                redo
              end
              break
            end

            raise ::ArgumentError, __say( st )
          end while nil

          NIL_
        end

        def left=
          @_left_glyph = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def right=
          @_right_glyph = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def sep=
          @_sep_glyph = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def gets_one_polymorphic_value
          @polymorphic_upstream_.gets_one
        end

        IG__ = Home_.lib_.parse::Item_Grammar.new(

          [
            :no_data,
            :left_aligned,
          ],
          :field,
          [
            :celify,
            :edit,
            :label,
            :map,
            :named,
            :summary,
          ] )

        def __say st
          "unrecognized table property: '#{ st.current_token }'"
        end

        def __accept_field fld

          fld = Field__.new fld
          @_bx.add fld.name_symbol, fld
          NIL_
        end

        # ~

        class Field__

          attr_reader(
            :does_summary,
            :name_symbol,
            :no_data,
            :summary_proc
          )

          def initialize fld

            @_custom_cel_expression = nil
            @_do_titlecase_generated_fields = true
            @does_sumary = false
            @_edit_proc = nil
            @_is_align_left = false
            @_label = nil
            @name_symbol = nil
            @no_data = false
            @_value_to_content_string_mapper = nil

            begin

              adj = fld.adj

              if adj
                if adj.left_aligned
                  @_is_align_left = true
                end
                if adj.no_data
                  @no_data = true
                end
              end

              edit_proc = nil

              pp = fld.pp
              if pp

                p = pp.celify
                if p
                  @_custom_cel_expression = p
                end

                edit_proc = pp.edit

                x = pp.label
                if x
                  @_label = x
                end

                x = pp.named
                if x
                  @name_symbol = x
                end

                p = pp.summary
                if p
                  @does_summary = true
                  @summary_proc = p
                end

                p = pp.map
                if  p
                  @_value_to_content_string_mapper = p
                end
              end

              if edit_proc

                x_a = nil
                pxy = Pxy___.new do | * x_a_ |
                  x_a = x_a_
                  NIL_
                end
                edit_proc[ pxy ]
                fld = IG__.parse_one_item_via_iambic_fully x_a
                redo
              end
              break
            end while nil

            @_value_to_content_string_mapper ||= V_TO_CS_M___
          end

          V_TO_CS_M___ = -> x do
            x.to_s  # false OK, nil OK
          end

          class Pxy___ < ::Proc
            alias_method :edit_table_field, :call
          end

          def some_header_content_string

            s = @_label
            if s
              s
            else
              @___inferred_label ||= __build_some_inferred_label
            end
          end

          def __build_some_inferred_label

            s = Callback_::Name.via_variegated_symbol( @name_symbol ).as_human
            if @_do_titlecase_generated_fields
              s = s.dup  # good job name class, you're frozen like u should be
              s[ 0 ] = s[ 0 ].upcase
            end
            s
          end

          def _map_value_to_content_string x

            @_value_to_content_string_mapper[ x ]
          end

          def __build_celify_header_proc ce, mx

            p = @_custom_cel_expression

            if p
              p[ ce, mx, false ]
            else

              format_s = _build_common_format_string ce, mx
              s = ce.mutable_string

              -> do
                s.replace format_s % s
                NIL_
              end
            end
          end

          def __build_celify_proc ce, mx

            p = @_custom_cel_expression
            if p
              p[ ce, mx, true ]
            else

              format_s = _build_common_format_string ce, mx
              s = ce.mutable_string

              -> dao do
                s.replace format_s % s
                NIL_
              end
            end
          end

          def _build_common_format_string ce, mx

            cel_w = mx.maxes.fetch ce.cel_index

            if @_is_align_left
              "%-#{ cel_w  }s"
            else
              "%#{ cel_w }s"
            end
          end
        end

        # ~ rendering

        attr_writer :expression_width

        def __build_glyph_function

          w = @_bx.length

          h = {}

          h[ 0 ] = @_left_glyph

          ( 1 ... w ).each do | d |
            h[ d ] = @_sep_glyph
          end

          h[ w ] = @_right_glyph

          -> d do
            h.fetch d
          end
        end

        def express_into_IO_data_tree io, tr  # #note-fm-315

          _y = ::Enumerator::Yielder.new do | s |
            io << "#{ s }#{ NEWLINE_ }"  # not `puts`. we are strict abt it
          end

          x = express_into_line_context_data_tree _y, tr
          x && io
        end

        def express_into_line_context_data_tree y, tr
          o = _begin
          o.downstream_lines = y
          o.summaries_argument = tr
          o.upstream_objects = tr.to_child_stream
          o.execute
        end

        def express_into_line_context_data_object_stream y, o_st
          o = _begin
          o.downstream_lines = y
          o.upstream_objects = o_st
          o.execute
        end

        def _begin

          o = Two_Pass_Render___.new
          o.do_show_header_row = @_do_show_header_row
          o.expression_width = @expression_width
          o.field_box = @_bx
          o.glyph_function = __build_glyph_function
          o
        end

        class Two_Pass_Render___

          def initialize
            @summaries_argument = nil
          end

          attr_writer(

            :do_show_header_row,
            :downstream_lines,
            :expression_width,
            :field_box,
            :glyph_function,
            :summaries_argument,
            :upstream_objects,
          )

          def execute

            @_w = @field_box.length

            __init_elements

            pcs = ::Array.new( ( @_w << 1 ) + 1 )

            __place_the_glyphs_only_once pcs

            __associate_fields_with_cels_and_render_glyphs pcs

            y = @downstream_lines

            @_flush_row = -> do

              y << ( pcs * EMPTY_S_ )
            end

            __express_any_header_row

            __express_body_and_summary_rows

            y
          end

          def __place_the_glyphs_only_once pcs

            @_row_element.glyphs_element.accept( Glyph_Visitor__.new do | g |

              pcs[ g.glyph_index << 1 ] = g.s

            end )
          end

          def __associate_fields_with_cels_and_render_glyphs pcs

            # in one pass, associate each field with its cel and ..

            @_row_element.cels_element.accept_by do | ce |

              pcs[ ( ce.cel_index << 1 ) + 1 ] = ce.mutable_string

              fld = @field_box.at_position ce.cel_index

              ce.__receive_field fld

              ce.__receive_celify_header_proc(
                fld.__build_celify_header_proc( ce, @_metrics ) )

              ce.__receive_celify_proc fld.__build_celify_proc( ce, @_metrics )

              NIL_
            end
          end

          def __express_any_header_row

            if @do_show_header_row
              @_row_element.cels_element.accept_by do | ce |
                _s = ce.field.some_header_content_string
                ce.mutable_string.replace _s
                ce.celify_header[]
              end
              @_flush_row[]
            end
          end

          def __express_body_and_summary_rows

            cels_element = @_row_element.cels_element

            @_content_matrix.rows_element.accept_by do | content_row_element |

              s_a = content_row_element.content_string_array
              dao = content_row_element.data_object

              if :_no_data_object_for_summary_row_ == dao

                cels_element.accept_by do | ce |

                  _s = s_a.fetch ce.cel_index

                  ce.mutable_string.replace _s

                  ce.celify_header[]
                end
              else

                cels_element.accept_by do | ce |

                  _s = s_a.fetch ce.cel_index

                  ce.mutable_string.replace _s

                  ce.celify[ dao ]
                end
              end
              @_flush_row[]
            end
          end

          def __init_elements

            cm = __produce_content_matrix

            re = Row_Element___.new @_w

            re.glyphs_element.accept( Glyph_Visitor__.new do | g |

              g.__receive_string @glyph_function[ g.glyph_index ]
            end )

            @_content_matrix = cm
            @_metrics = Metrics___.new @expression_width, re, cm
            @_row_element = re
            NIL_
          end

          def __produce_content_matrix

            o = Build_content_matrix___.new
            o.do_show_header_row = @do_show_header_row
            o.field_box = @field_box
            o.summaries_argument = @summaries_argument
            o.upstream_objects = @upstream_objects
            o.execute
          end
        end

        class Build_content_matrix___  # srp

          attr_writer(

            :do_show_header_row,
            :field_box,
            :summaries_argument,
            :upstream_objects,
          )

          def execute

            __initial_horizontal_pass
            __init_see_content_proc
            __see_header_row
            __gather_up_body
            __do_summary_row

            Content_Matrix___.new @_column_widths, @_content_row_a
          end

          def __initial_horizontal_pass

            fld_bx = @field_box
            @_w = fld_bx.length
            fld_a = ::Array.new @_w

            @_accept = -> & visit_p do  # visitor pattern sort of
              @_w.times do | d |
                visit_p.call d, fld_a.fetch( d )
              end
            end

            do_summary_row = false
            @_accept.call do | d, _ |

              fld = fld_bx.at_position d
              fld_a[ d ] = fld
              if fld.does_summary
                do_summary_row = true
              end
            end

            @_do_summary_row = do_summary_row
            NIL_
          end

          def __see_header_row

            if @do_show_header_row

              @_accept.call do | d, fld |
                @_see_content[ fld.some_header_content_string, d ]
              end
            end
          end

          def __gather_up_body

            m_a = @field_box.a_
            see = @_see_content
            st = @upstream_objects
            @_content_row_a = []

            begin
              o = st.gets
              o or break

              _row o do | row_a |

                @_accept.call do | d, fld |

                  s = if fld.no_data
                    EMPTY_S_
                  else
                    _s_ = o.send m_a.fetch d
                    _ = fld._map_value_to_content_string _s_
                    _ or self._SANITY
                  end
                  row_a[ d ] = s
                  see[ s, d ]
                  NIL_
                end
              end
              redo
            end while nil
            NIL_
          end

          def __do_summary_row

            if @_do_summary_row

              _row :_no_data_object_for_summary_row_ do | row_a |

                @_accept.call do | d, fld |
                  s = if fld.does_summary
                    fld.summary_proc[ @summaries_argument ]
                  else
                    EMPTY_S_
                  end
                  @_see_content[ s, d ]
                  row_a[ d ] = s
                  NIL_
                end
              end
            end
          end

          def __init_see_content_proc

            maxes = @_w.times.map { 0 }
            @_column_widths = maxes
            @_see_content = -> s, d do
              d_ = s.length
              if maxes.fetch( d ) < d_
                maxes[ d ] = d_
              end
              NIL_
            end
          end

          def _row o

            cel_a = ::Array.new @_w
            _cre = Content_Row_Element___.new cel_a, o
            @_content_row_a.push _cre
            yield cel_a
          end
        end

        class Content_Matrix___

          attr_reader(
            :rows_element,
            :maxes,
          )

          def initialize maxes, content_row_a
            @rows_element = Content_Rows_Element___.new content_row_a
            @maxes = maxes
          end
        end

        class Content_Rows_Element___

          def initialize x
            @_row_element_a = x
          end

          def accept_by & visit_p
            @_row_element_a.each( & visit_p )
            NIL_
          end
        end

        class Content_Row_Element___

          attr_reader(
            :data_object,
            :content_string_array,
          )

          def initialize cel_a, o
            @content_string_array = cel_a
            @data_object = o
          end
        end

        class Row_Element___

          attr_reader(
            :cels_element,
            :glyphs_element,
          )

          def initialize w
            @cels_element = Cels_Element__.new w
            @glyphs_element = Glyphs_Element__.new w
          end
        end

        class Glyphs_Element__

          def initialize w

            @_glyphs = ( w + 1 ).times.map do | d |
              Glyph_Element___.new d
            end
          end

          def accept visitor

            @_glyphs.each do | glyph |
              glyph.accept visitor
            end
            NIL_
          end
        end

        class Cels_Element__

          def initialize w

            @_cels = w.times.map do | d |
              Cel_Element___.new  d
            end
          end

          def accept_by & visitor_p

            @_cels.each do | cel |
              cel.accept_by( & visitor_p )
            end
            NIL_
          end
        end

        class Glyph_Element___

          attr_reader(
            :glyph_index,
            :s
          )

          def initialize d
            @glyph_index = d
          end

          def accept visitor
            visitor.visit__glyph_element__ self
            NIL_
          end

          def __receive_string s
            @s = s
            NIL_
          end
        end

        class Cel_Element___

          def initialize d
            @cel_index = d
            @mutable_string = ""
          end

          attr_reader(
            :cel_index,
            :celify,
            :celify_header,
            :field,
            :mutable_string,
          )

          def accept_by( & visitor_p )
            visitor_p[ self ]
            NIL_
          end

          def __receive_field x
            @field = x
          end

          def __receive_celify_proc p
            @celify = p
          end

          def __receive_celify_header_proc p
            @celify_header = p
          end
        end

        class Metrics___

          attr_reader(
            :maxes,
            :width,
            :width_so_far,
          )

          def initialize expression_width, re, cm

            d = cm.maxes.reduce :+

            re.glyphs_element.accept( Glyph_Visitor__.new do | g |
              d += g.s.length
            end )

            @maxes = cm.maxes
            @width = expression_width
            @width_so_far = d
          end
        end

        class Glyph_Visitor__ < ::Proc

          alias_method :visit__glyph_element__, :call
        end
      end

      # <- 2

end
