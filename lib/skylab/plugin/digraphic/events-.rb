module Skylab

  module Plugin

    class Digraphic

      Events_ = ::Module.new

      _Ev = Callback_::Event

      Events_::Ambiguous_Next_Step = _Ev.prototype_with :ambiguous_next_step,

          :steps, nil, :plugin_a, nil, :digraph, nil do | y, o |

        a = o.steps.map do | step |
          o.plugin_a.fetch( step.plugin_idx ).name.as_human
        end

        _v = o.digraph.
          transition( o.steps.first.transition_symbol ).name.as_human

        y << "input has ambiguity - #{ both a }#{ and_ a } #{
          }want to #{ _v }"

      end

      Events_::Unused_Actuals = _Ev.prototype_with :unused_actuals,

          :box, nil, :steps, nil, :plugins, nil do | y, o |

        # just for fun we make a hand-written :+[#hu-002] EN expression of
        # aggregation:
        #
        # "the application would finish by expressing help before it would
        # build hob-nobbers or flush dingle-hoofers, making the '--foo'
        # option meaningless. also, '--x' would never be processed because
        # zipping the dipple [ or dopping the nopple ] would never happen."
        #
        # sentence 1 and sentence 2..N have different templates, which we
        # implement by processing the matrix as a stream.

        formal_and_plugins_matrix = o.box.to_enum( :each_value ).map do | unused_a |

          fo = nil
          _or_s_a = unused_a.map do | unused |

            fo ||= unused.formal  # use the first one for its name

            _pu = o.plugins.fetch( unused.plugin_idx )

            _pu.name.as_human

          end
          [ fo, _or_s_a ]
        end

        st = Callback_::Stream.via_nonsparse_array formal_and_plugins_matrix

        fo, or_s_a = st.gets

        pu = o.plugins.fetch o.steps.last.plugin_idx

        y << "the application would finish by #{
         }#{ progressive_verb pu.name.as_human } #{
          }before it would #{ or_ or_s_a }, making the #{
           }'#{ fo.local_identifier_x }' option meaningless."

        begin
          fo, or_s_a = st.gets
          fo or break
          or_s_a.map!( & method( :progressive_verb ) )

          y << "also, '#{ fo.local_identifier_x }' would never be processed #{
           }because #{ or_ or_s_a } would never happen"

          redo
        end while nil
      end

      class Events_::Express_Help < Callback_::Event

        class << self
          public :new
        end  # >>

        def initialize resources, & oes_p
          @rsc = resources
          @on_event_selectively = oes_p
        end

        def execute
          @on_event_selectively.call :help, :event do
            self
          end
        end

        def message_proc
          oes_p = @on_event_selectively
          -> y, o do
            Render___.new( y, o.__dsp, o.rsc, self, & oes_p ).execute
          end
        end

        attr_reader :rsc

        def __dsp
          @on_event_selectively.call :for_plugin, :dispatcher  # experimental
        end

        class Render___

          def initialize into_y, dsp, rsc, expag, & oes_p
            @content_has_been_displayed = false
            @dg = dsp.digraph
            @expag = expag
            @on_event_selectively = oes_p
            @plugins = dsp.plugin_a
            @y = into_y
          end

          def execute
            __init_args_list_and_options_box
            __render
          end

          def __init_args_list_and_options_box

            a = nil
            bx = Callback_::Box.new

            @plugins.each do | pu |

              if pu.respond_to? :process_ARGV
                ( a ||= [] ).push pu
              end

              pu.each_reaction do | tr |

                tr.each_catalyzing_formal do | fo |

                  bx.touch( fo.local_identifier_x ) { [] }.push [ fo, pu ]

                end

                tr.each_ancillary_formal_option do | fo |

                  bx.touch( fo.local_identifier_x ) { [] }.push [ fo, pu ]

                end
              end

              pu.each_capability do | tr |

                tr.each_ancillary_formal_option do | fo |

                  bx.touch( fo.local_identifier_x ) { [] }.push [ fo, pu ]

                end
              end
            end

            @takes_ARGV_pu_a = a
            @bx = bx ; nil
          end

          def __render

            if @takes_ARGV_pu_a
              __render_usage_and_arguments
            end

            __render_options
          end

          def __render_usage_and_arguments

            _pn = @on_event_selectively.call :for_plugin, :program_name

            s_a = @takes_ARGV_pu_a.reduce [] do | m, pu |
              s = pu.description_for_ARGV_syntax_under @expag
              s and m.push s
              m
            end

            if s_a.length.nonzero?
              _args = " #{ s_a * SPACE_ }"
            end

            y = @y
            @expag.calculate do
              y << "#{ hdr( 'usage:' ) } #{ _pn } [opts]#{ _args }\n"
            end

            @content_has_been_displayed = true

            nil
          end

          def __render_options

            y = @y

            @content_has_been_displayed and y << "\n"

            @expag.calculate do
              y <<  "#{ hdr( 'options:' ) }\n"
            end

            @mat_a = []

            @bx.each_value do | fo_a |
              __write_to_matrix_formal_group_under fo_a
            end

            Home_.lib_.IN_MOTION_table_actor(

              :left, '  ',
              :right, EMPTY_S_,
              :sep, '  ',
              :field, :right,
              :field, :left,
              :header, :none,

              :read_rows_from, @mat_a,
              :write_lines_to, y )

            ACHIEVED_
          end

          def __write_to_matrix_formal_group_under fo_a

            __write_to_matrix_first_formal fo_a

            __write_to_matrix_nonfirst_formals fo_a

            nil
          end

          def __write_to_matrix_first_formal fo_a

            fo, pu = fo_a.first
            s = fo.full_pedagogic_moniker_rendered_under @expag

            st = fo.to_description_line_stream_rendered_under @expag

            line = st.gets

            @mat_a.push [ s ]
            if line
              _maybe_add_thing line, fo, pu
              _flush_into_matrix_stream st, fo, pu
            else
              _maybe_add_thing line, fo, pu
            end
            nil
          end

          def __write_to_matrix_nonfirst_formals fo_a

            fo_a[ 1 .. -1 ].each do | fo, pu |

              _st = fo.to_description_line_stream_rendered_under @expag

              _flush_into_matrix_stream _st, fo, pu
            end

            nil
          end

          def _flush_into_matrix_stream st, fo, pu

            begin
              line = st.gets
              line or break
              _maybe_add_thing line, fo, pu
              redo
            end while nil
          end

          def _maybe_add_thing line, fo, pu

            # massive hacking ahead. everything is a proof of concept.
            # none of this is real.

            pth_x = fo.formal_path_x

            if :catalyzing_formals == pth_x[ 1 ]

              if line
                _add_cel "#{ line }."

              else
                # (it can be fun to do both this branch and the above one,
                # but in practice, this generated language is usually less
                # specific than and otherwise redundant with the above.)

                _s = @expag.calculate do
                  third_person pu.name.as_human
                end
                _add_cel "#{ _s }."
              end

            elsif :ancillary_formals == pth_x[ 1 ]

              _s = @expag.calculate do
                "while #{ progressive_verb pu.name.as_human },"
              end

              _add_cel _s

              if line
                _add_cel "#{ line }."
              end
            end
            nil
          end

          def _add_cel cel_s
            row = @mat_a.last
            if 1 == row.length
              row.push cel_s
            else
              @mat_a.push [ nil, cel_s ]
            end ; nil
          end
        end
      end
    end
  end
end
