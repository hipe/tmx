module Skylab::BeautySalon

  class Models_::Text

    Actions = ::Module.new

    class Actions::Wrap < Brazen_::Model.common_action_class  # :[#033]., :+[#ba-033]

      @is_promoted = true

      Brazen_::Model.common_entity self,

        :ad_hoc_normalizer, -> arg, & oes_p do
          Normalize_line_ranges___.new( arg, & oes_p ).execute
        end,
        :default, '1-',
        :property, :lines,

        :ad_hoc_normalizer, -> arg, & oes_p do

          # ( was :+[#ba-027] with [#fa-019] shape )

          Home_.lib_.basic::Number.normalization.with(
            :number_set, :integer,
            :minimum, 1,
            :argument, arg, & oes_p )
        end,

        :required, :property, :num_chars_wide,

        :flag, :property, :preview,

        :flag, :property, :verbose,

        :flag, :property, :number_the_lines,

        :required, :property, :input_path

      def accept_selective_listener_proc oes_p

        # #experimentally we retro-fit this to accomodate our hacky new
        # way to get arbitrary resources from parent. might go up.

        hesvc_p = -> i_a, & ev_p do

          if :for_action == i_a.first  # then there is probably no ev_p
            oes_p[ * i_a, & ev_p ]

          elsif :expression == i_a[ 1 ]  # same idea, different thing  (:+[#br-023])
            oes_p[ * i_a, & ev_p ]

          else

            maybe_emit_wrapped_or_autovivified_event oes_p, i_a, & ev_p
          end
        end

        @on_event_selectively = -> * i_a, & ev_p do
          hesvc_p[ i_a, & ev_p ]
        end

        @__HESVC_p__ = hesvc_p
        nil
      end

      def produce_result

        __init_ivars
        __inspect_union

        _ok = __resolve_line_upstream
        _ok && __process_upstream_lines
      end

      def __init_ivars

        h = @argument_box.h_
        @be_verbose = h[ :verbose ]
        @do_number_the_lines = h[ :number_the_lines ]
        @do_preview = h[ :preview ]

        @informational_downstream =
          @on_event_selectively.call :for_action, :informational_bytestream

        __HEADER = if @do_preview && @be_verbose &&  @do_number_the_lines
          "     + "
        end

        @line_buffer = Text_::Sessions_::Wrapping_Buffer.new(
          h.fetch( :num_chars_wide ),
          -> line do
            @downstream.write "#{ __HEADER }#{ line }"
          end )

        @line_range_union = h.fetch :lines

        @line_range_union ||= self._DESIGN_ME


        @line_no_fmt = '%4d'

        @token_buffer = Home_.lib_.token_buffer %r([[:space:]]*), %r([^[:space:]]+)

        @upstream_path = h.fetch :input_path

        # ~

        @downstream = if @do_preview
          @informational_downstream
        else
          @on_event_selectively.call :for_action, :output_bytestream
        end

        nil
      end

      def __inspect_union

        if @be_verbose

          lru = @line_range_union

          @on_event_selectively.call :info, :expression, :line_range_union do | y |
            y << "(line range union: #{ lru.description_under self })\n"
          end
        end
      end

      def __resolve_line_upstream
        io = __produce_open_file_IO
        io and begin
          @line_upstream = Home_.lib_.list_scanner io
          ACHIEVED_
        end
      end

      def __produce_open_file_IO

        Home_.lib_.system.filesystem( :Upstream_IO ).against_path(
          @upstream_path,
          & @on_event_selectively )
      end

      def __process_upstream_lines

        line = @line_upstream.gets
        if line
          __process_nonzero_upstream_lines line

        else
          __when_file_has_no_lines

        end
      end

      def __when_file_has_no_lines

        path = @upstream_path

        @on_event_selectively.call :info, :expression, :empty_file do | y |

          y < "(file had no lines - #{ pth path })"
        end

        ACHIEVED_
      end

      def __process_nonzero_upstream_lines line

        did_engage = false
        downstream = @downstream
        info_down = @informational_downstream

        hot_line = -> do
          did_engage = true
          hot_line = -> do
            __receive_line line
          end
          hot_line[]
        end

        cold_line = if @do_preview
          if @do_number_the_lines
            -> do
              info_down.puts " #{ @line_no_fmt % @line_upstream.line_number }#{
                }: #{ line }"
              NIL_
            end
          else
            -> do
              info_down.puts line
              NIL_
            end
          end
        else
          -> do
            downstream.write line
            NIL_
          end
        end

        ok = true
        begin
          if @line_range_union.include? @line_upstream.line_number
            ok = hot_line[]
            ok or break
          else
            cold_line[]
          end
          line = @line_upstream.gets
          line or break
          redo
        end while nil

        ok and begin
          if did_engage
            ACHIEVED_
          else
            __when_no_lines_were_in_range
          end
        end
      end

      def __when_no_lines_were_in_range

        d = @line_upstream.count
        lru = @line_range_union

        @on_event_selectively.call :info, :expression do | y |

          y << "(the lines of the file (#{
            }#{ d.zero? ? 'none' : "1-#{ d }" }) did not #{
             }intersect with the selected lines (#{
              }#{ lru.description_under self }))"
        end

        UNABLE_
      end

      def __receive_line line

        # "regreverness": regrettable cleverness

        @token_buffer.gets_proc = -> do

          @token_buffer.gets_proc = -> do
            if @line_range_union.include?( @line_upstream.count + 1 )
              @line_upstream.gets
            end
          end

          line
        end

        begin
          word = @token_buffer.gets
          word or break
          @line_buffer << word
          redo
        end while nil

        @line_buffer.flush

        ACHIEVED_
      end

      # ~

      class Normalize_line_ranges___

        # :+[#fa-019] (still?) assume that x is nil or an array.

        def initialize arg, & oes_p
          @arg = arg ; @on_event_selectively = oes_p
        end

        def execute
          @x = @arg.value_x
          if @x
            __when_value
          else
            @arg  # leave it as-is
          end
        end

        def __when_value

          @upstream = Home_.lib_.list_scanner @x
          __init_range_list_scanner
          __init_union

          @ok = true

          begin
            x = @upstream.gets
            x or break
            @rls.string = x
            begin
              x = @rls.gets
              x or break
              x = @union.add x
              x or break
              redo
            end while nil
            redo
          end while nil

          if @ok
            @arg.new_with_value @union.prune
          else
            UNABLE_
          end
        end

        def __init_range_list_scanner

          pa = Home_.lib_.basic::Range::Positive::List::Scanner.new

          pa.unexpected_proc = -> x, exp_a do

            __when_bad_range x, exp_a

            STOP_PARSING_
          end

          @rls = pa ; nil
        end

        def __when_bad_range x, exp_a

          @ok = false

          @on_event_selectively.call :error, :invalid_property_value, :lines do


            Callback_::Event.inline_not_OK_with :invalid_range,
                :x, x, :exp_a, exp_a do | y, o |

              _excerpt = ellipsulate__ o.x

              y << "didn't understand \"#{ _excerpt }\" in the #{
               }lines expression - expected a #{ or_ exp_a  }"
            end
          end

          nil
        end

        def __init_union

          un = Home_.lib_.basic::Range::Positive::Union.new

          un.unexpected_proc = -> msg_s do

            @ok = false

            @on_event_selectively.call :error, :invalid_property_value, :lines do

              Callback_::Event.inline_not_OK_with :invalid_lines_identifier, :s, s do | y, o |

                y << "can't understand lines because #{ o.s }"
              end
            end
          end

          @union = un ; nil
        end
      end
    end

    Text_ = self
  end
end
