module Skylab::BeautySalon

  module Models_::Text

    Actions = ::Module.new  # while #open [#now]

    class Actions::Wrap  # :[#033].

      Actions = nil  # WHY  # while #open [#now]

      # near #[#ba-033] the word wrap narrative

      class << self
        def describe_into_under y, expag
          expag.calculate y, & Describe_into__
        end
      end  # >>

      Describe_into__ = -> y do

        _big_str = <<~HERE
            outputs to stdout (unless stated otherwise) the selected lines
            after having applied the hacky wrap filter to it (effectively re-
            breaking the lines so they are flush-left ragged right, and all
            with a width less than or equal to some indicated positive non-zero
            integer.

            NOTE a) this is just an exploratory hack, "we are doing it wrong",
            and b) this is NOT intended for code, only comments or very simple
            markdown-ish.
        HERE

        _st = Basic_[]::String::LineStream_via_String[ _big_str ]
        _st.join_into y
      end

      # used to: :inflect, :noun, :lemma_string,  # say "couldn't wrap text", not "couldn't wrap a text"

      def definition ; [

        :description, Describe_into__,

        :required,
        :property, :output_bytestream,

        :required,
        :property, :informational_downstream,

        :property, :lines,
        :description, -> y do
          y << 'apply the filter only to this range of lines (e.g "-l 1-16,26-38").'
          y << "a range can be a single number. multiple ranges can be specified"
          y << "using the comma, also the `--lines` option may be employed multiple"
          y << "times. ranges that do not \"make sense\" will lead to an alternate"
          y << "early ending (error); but out of bounds ranges are silently"
          y << "ignored. see how overlapping ranges are processed by turning"
          y << "on `--verbose`."
        end,

        :normalize_by, -> qkn, & p do
          self._COVER_ME__probably_fine__
          LineRanges_via_String__.new( qkn, & p ).execute
        end,

        :default_by, -> _op, & _p do
          Default_line_ranges___[]
        end,

        :required,
        :property, :num_chars_wide,
        :description, -> y do

          prp = action_reflection.front_properties.fetch :num_chars_wide
          prp.has_primitive_default or fail
          _x = prp.primitive_default_value

          y << "how wide can the longest line be? (default: #{ val _x })"
        end,
        :default, 80,
        :normalize_by, -> qkn, & oes_p do

          # ( was #[#fi-004.5], used to have what is now [#br.024.C] shape )

          if qkn.is_known_known
            Basic_[]::Number::Normalization.via(
              :number_set, :integer,
              :minimum, 1,
              :qualified_knownness, qkn, & oes_p )
          else
            qkn  # required-ness is out of our scope
          end
        end,

        :flag,
        :property, :preview,
        :description, -> y do
          y << 'output only those output lines that are the'
          y << 'result of the input lines indicated by `--lines`.'
          y << 'all output goes to stderr.'
        end,

        :flag,
        :property, :verbose,
        :description, -> y do
          y << 'verbose output'
        end,

        :flag,
        :property, :number_the_lines,
        :description, -> y do
          y << 'Number the output lines, starting at 1.'
          y << "(only honored in verbose preview mode for now..)"
        end,

        :required,
        :property, :upstream,
      ] ; end

      def initialize
        o = yield
        @_argument_scanner_ = o.argument_scanner
      end

      def execute

        __init_ivars
        __inspect_union
        __process_upstream_lines
      end

      def __init_ivars

        # -- (adopt our local idiom for boolean parameters, for now (bridge to legacy))

        @do_number_the_lines = remove_instance_variable :@number_the_lines

        @do_preview = remove_instance_variable :@preview

        @be_verbose = remove_instance_variable :@verbose

        # -- (other name changes (bridge to legacy))

        @line_range_union = remove_instance_variable :@lines

        # --

        __HEADER = if @do_preview && @be_verbose && @do_number_the_lines
          "     + "
        end

        @line_buffer = Text_::WrappedLines_via_Lines_and_Width___.new(
          @num_chars_wide,
          -> line do
            @downstream << "#{ __HEADER }#{ line }"
          end )

        @token_buffer = Basic_[]::Token::Buffer.new(
          %r([[:space:]]*),
          %r([^[:space:]]+),
        )

        @line_range_union ||= self._DESIGN_ME

        @line_no_fmt = '%4d'

        # ~

        ob = remove_instance_variable :@output_bytestream

        @downstream = if @do_preview
          @informational_downstream
        else
          ob
        end

        NIL_
      end

      def __inspect_union

        if @be_verbose

          lru = @line_range_union

          _listener_.call :info, :expression, :line_range_union do | y |
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

        _listener_.call :info, :expression, :empty_file do | y |

          y < "(file had no lines - #{ pth path })"
        end

        _maybe_close_upstream

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
          if line
            redo
          end
          _maybe_close_upstream
          break
        end while nil

        ok and begin
          if did_engage
            NIL_AS_SUCCESS_
          else
            __when_no_lines_were_in_range
          end
        end
      end

      def _maybe_close_upstream
        @upstream.close  # ..
        NIL
      end

      def __when_no_lines_were_in_range

        d = @upstream.lineno
        lru = @line_range_union

        _listener_.call :info, :expression do | y |

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

      def _listener_  # override our more complicated way FOR NOW ..
        @_argument_scanner_.listener
      end

      include CommonActionMethods_

      # ==

      class LineRanges_via_String__  # 1x

        # #[#br-024.3] (still?) assume that x is nil or an array.

        def initialize qkn, & p

          @listener = p
          @qualified_knownness = qkn
        end

        def execute
          @x = @qualified_knownness.value
          if @x
            __when_value
          else
            @qualified_knownness.to_knownness  # leave value as-is
          end
        end

        def __when_value

          @upstream = Common_::Stream::Magnetics::MinimalStream_via[ @x ]
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
            Common_::KnownKnown[ @union.prune ]
          else
            UNABLE_
          end
        end

        def __init_range_list_scanner

          pa = Basic_[]::Range::Positive::List::Scanner.new

          pa.unexpected_proc = -> x, exp_a do

            __when_bad_range x, exp_a

            STOP_PARSING_
          end

          @rls = pa ; nil
        end

        def __when_bad_range x, exp_a

          @ok = false

          @listener.call :error, :invalid_property_value, :lines do

            Common_::Event.inline_not_OK_with :invalid_range,
                :x, x, :exp_a, exp_a do | y, o |

              _excerpt = ellipsulate__ o.x

              y << "didn't understand \"#{ _excerpt }\" in the #{
               }lines expression - expected a #{ or_ exp_a  }"
            end
          end

          nil
        end

        def __init_union

          un = Basic_[]::Range::Positive::Union.new

          un.unexpected_proc = -> msg_s do

            @ok = false

            @listener.call :error, :invalid_property_value, :lines do

              Common_::Event.inline_not_OK_with :invalid_lines_identifier, :s, s do | y, o |

                y << "can't understand lines because #{ o.s }"
              end
            end
          end

          @union = un ; nil
        end
      end  # normalize line ranges

      # ==

      Default_line_ranges___ = Lazy_.call do

        _arg = Common_::QualifiedKnownKnown.via_value_and_symbol '1-', NOTHING_
        LineRanges_via_String__.new( _arg ).execute
      end

      # ==
      # ==
    end

    NIL_AS_SUCCESS_ = nil  # side-effects only
    Text_ = self
  end
end
# history-A.1: begin wean off matryoshka
