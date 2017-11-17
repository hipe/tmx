module Skylab::MyTerm

  class Models_::Font

    class Collection_Controller___

      # implement the common collection based operations (list, lookup)
      # while emitting informational events about edge cases (like if no
      # fonts were found at all in the installation).
      #
      # (used to use Emit_by_adding_verb_, furloughed temporarily while
      # we revisit event wiring..)

      def initialize k, & pp

        1 == pp.arity or self._NEEDED_pp_probably_had_p_README

        # subject is produced to assist both opertions and associations
        # (components) so we must use the lowest common denominator shape
        # of handler here (the `pp` not the `p`).

        @_do_summarize = true  # eew - e.g for "did you mean", don't repeat

        @_listener = pp[ nil ]

        @kernel_ = k

        _inst = _installation
        @_fonts_dir = _inst.fonts_dir
      end

      def lookup_font_path__ _action_sym, path

        _ = Home_.lib_.brazen::Magnetics::Item_via_FeatureBranch::FYZZY.call_by do |o|

          o.set_qualified_knownness_value_and_symbol path, :font_path

          o.item_stream_by do
            to_expressing_path_stream_
          end

          p = -> path_ do
            # (it makes the "did you mean.." more interesting if we strip
            #  the extension from these.. might bite later)
            bn = ::File.basename path_
            d = ::File.extname( bn ).length
            d.zero? ? bn : bn[ 0 ... -d ].downcase
          end

          o.string_via_item = p

          o.string_via_target = p

          o.levenshtein_number = 3

          o.listener = @_listener
        end
        _  # hi.
      end

      def to_expressing_path_stream_

        saw_none = true
        skipped =  nil

        st = __build_nonreduced_path_stream

        pass_ = __build_pass_filter
        pass = -> path do

          yes = pass_[ path ]
          if yes
            saw_none = false
            pass = pass_
          end
          yes
        end

        p = -> do
          begin
            path = st.gets

            if ! path
               p = EMPTY_P_
               __maybe_express_summary saw_none, skipped
               break
            end

            if pass[ path ]
              x = path
              break
            end

            skipped ||= ::Hash.new 0
            skipped[ ::File.extname path ] += 1
            redo
          end while nil
          x
        end

        Common_.stream do
          p[]
        end
      end

      def __maybe_express_summary saw_none, skipped
        if @_do_summarize
          @_do_summarize = false
          ___express_summary saw_none, skipped
        end
        NIL_
      end

      def ___express_summary saw_none, skipped

        fonts_dir = @_fonts_dir

        if saw_none
          @_listener.call :info, :expression, :not_found do |y|
            y << "(no fonts found - #{ pth fonts_dir })"
          end
        end

        if skipped
          @_listener.call :info, :expression, :skipped do |y|
            y << "(skipped: #{ skipped.inspect })"
          end
        end

        NIL_
      end

      def __build_nonreduced_path_stream

        _glob_path = "#{ @_fonts_dir }/*"

        _paths = _installation.filesystem.glob _glob_path

        Common_::Stream.via_nonsparse_array _paths
      end

      def __build_pass_filter

        _inst = _installation

        _a = _inst.font_file_extensions

        h = ::Hash[ _a.map { |s| [ ".#{ s }", true ] } ]

        -> path do
          h[ ::File.extname path ]
        end
      end

      def _installation
        @kernel_.silo :Installation
      end

      EMPTY_P_ = -> { NIL_ }
    end
  end
end
