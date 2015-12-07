module Skylab::BeautySalon

  module Models_::Text

    Actions = ::Module.new

    Brazen_ = Home_.lib_.brazen

    class Actions::Wrap < Brazen_::Action  # :[#033]., :+[#ba-033]

      @is_promoted = true

      Brazen_::Modelesque.entity( self,

        :branch_description, -> y do

          s = <<-HERE
            outputs to stdout (unless stated otherwise) the selected lines
            after having applied the hacky wrap filter to it (effectively re-
            breaking the lines so they are flush-left ragged right, and all
            with a width less than or equal to some indicated positive non-zero
            integer.

            NOTE a) this is just an exploratory hack, "we are doing it wrong",
            and b) this is NOT intended for code, only comments or very simple
            markdown-ish.
          HERE

          st = Home_.lib_.basic::String[ :line_stream, :mutate_by_unindenting, s ]
          y << s while s = st.gets
        end,

        :required,
        :property, :output_bytestream,

        :required,
        :property, :informational_downstream,

        :description, -> y do
          y << 'apply the filter only to this range of lines (e.g "-l 1-16,26-38").'
          y << "a range can be a single number. multiple ranges can be specified"
          y << "using the comma, also the `--lines` option may be employed multiple"
          y << "times. ranges that do not \"make sense\" will lead to an alternate"
          y << "early ending (error); but out of bounds ranges are silently"
          y << "ignored. see how overlapping ranges are processed by turning"
          y << "on `--verbose`."
        end,
        :ad_hoc_normalizer, -> arg, & oes_p do
          Actors_::Normalize_line_ranges.new( arg, & oes_p ).execute
        end,
        :default, '1-',
        :property, :lines,

        :description, -> y do

          prp = action_reflection.front_properties.fetch :num_chars_wide
          prp.has_primitive_default or fail
          _x = prp.primitive_default_value

          y << "how wide can the longest line be? (default: #{ val _x })"
        end,
        :default, 80,
        :ad_hoc_normalizer, -> qkn, & oes_p do

          # ( was :+[#ba-027], used to have what is now [#br.024.C] shape )

          if qkn.is_known_known
            Home_.lib_.basic::Number.normalization.with(
              :number_set, :integer,
              :minimum, 1,
              :qualified_knownness, qkn, & oes_p )
          else
            qkn  # required-ness is out of our scope
          end
        end,
        :required,
        :property, :num_chars_wide,

        :flag,
        :description, -> y do
          y << 'output only those output lines that are the'
          y << 'result of the input lines indicated by `--lines`.'
          y << 'all output goes to stderr.'
        end,
        :property, :preview,

        :flag,
        :description, -> y do
          y << 'verbose output'
        end,
        :property, :verbose,

        :flag,
        :description, -> y do
          y << 'Number the output lines, starting at 1.'
          y << "(only honored in verbose preview mode for now..)"
        end,
        :property, :number_the_lines,

        :required,
        :property, :upstream,
      )

      def produce_result

        __init_ivars
        __inspect_union
        __process_upstream_lines
      end

      def __init_ivars

        h = @argument_box.h_
        @be_verbose = h[ :verbose ]
        @do_number_the_lines = h[ :number_the_lines ]
        @do_preview = h[ :preview ]

        @informational_downstream = h.fetch :informational_downstream

        __HEADER = if @do_preview && @be_verbose && @do_number_the_lines
          "     + "
        end

        @line_buffer = Text_::Sessions_::Wrapping_Buffer.new(
          h.fetch( :num_chars_wide ),
          -> line do
            @downstream << "#{ __HEADER }#{ line }"
          end )

        @line_range_union = h.fetch :lines

        @line_range_union ||= self._DESIGN_ME

        @line_no_fmt = '%4d'

        @token_buffer = Home_.lib_.token_buffer %r([[:space:]]*), %r([^[:space:]]+)

        @upstream = h.fetch :upstream

        # ~

        @downstream = if @do_preview
          @informational_downstream
        else
          h.fetch :output_bytestream
        end

        NIL_
      end

      def __inspect_union

        if @be_verbose

          lru = @line_range_union

          @on_event_selectively.call :info, :expression, :line_range_union do | y |
            y << "(line range union: #{ lru.description_under self })\n"
          end
        end
      end

      def __process_upstream_lines

        line = @upstream.gets
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
              info_down.puts " #{ @line_no_fmt % @upstream.lineno }#{
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
            downstream << line
            NIL_
          end
        end

        ok = true
        begin
          if @line_range_union.include? @upstream.lineno
            ok = hot_line[]
            ok or break
          else
            cold_line[]
          end
          line = @upstream.gets
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

        d = @upstream.lineno
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
            if @line_range_union.include?( @upstream.lineno + 1 )
              @upstream.gets
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

      Actors_ = ::Module.new
      class Actors_::Normalize_line_ranges  # 1x

        # :+[#br-024.C] (still?) assume that x is nil or an array.

        def initialize arg, & oes_p

          @on_event_selectively = oes_p
          @_qualified_knownness = arg
        end

        def execute
          @x = @_qualified_knownness.value_x
          if @x
            __when_value
          else
            @_qualified_knownness.to_knownness  # leave value as-is
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
            Callback_::Known_Known[ @union.prune ]
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
