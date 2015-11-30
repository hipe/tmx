module Skylab::TestSupport

  module Quickie

    class Plugins::Order

      def __big_string

        flag = _flag

        <<-HERE.unindent
          this plugin is inspired by -depth (see), and perhaps supersedes it.

          this plugin is concerned with how the tree of spec files is
          flattened into an ordered list. we created it because the
          filesystem (or `find` command?) doesn't reliably produce the list
          of spec files in a "regression-friendly" order.

          we sort the spec paths using the following two rules.
          the first rule trumps the second rule.

          1) within a directory, files come before directories.

          2) entries whose names have a leading integer come before those
             without.

          this effectively subdivides each directory into two groups,
          each of which is itself sub-divided into two more groups:

          the entries *without* leading integers are sorted lexically by
          whatever is the platform definition of "lexical."

          the entries *with* leading integers are sorted in ascending order
          by integer.

            • a zero-padded integer is identical to the same integer without
              padding, so padding can be used aesthetically in filenames
              with no impact on the sort.

            • the integer parsing stops at any first character that is not
              an integer, so [ "1A", "1.5A" ] will not sort as you might
              like (for now). (because "A" comes before "." lexically.)

            • we do not define behavior for what happens when two different
              entries have the same effective integer.

          this sort criteria is effected recursively on each directory.

          NOW, if you understand all that we are ready to begin explaining
          what the arguments do: `#{ flag }=M-N` says "run the spec files
          'M' thru 'N' inclusive" where 'M' and 'N' are *ordinal* numbers
          referencing the files in the sorted list, starting from 1.

          so, `#{ flag }=1-3` will run the first, second and third spec
          file in the ordered list.

          using zero or will trip an error. negative numbers are not yet
          supported.

          you can use the literal string 'N' (without the quotes) to signify
          the last file in the ordered list, so if there are six spec files,
          so `#{ flag }=4-N` will do the fourth, fifth and sixth files.
          `#{ flag }=1-N` will always do all the files in order, however
          many files there are.

          FINALLY, flipping the order of the two numbers so that the 'N'
          term comes before the 'M' term will reverse the order of the files.
          `#{ flag }=3-1` will do the third, second, then first file.
          `#{ flag }=N-4` wil do the sixth, fifth, then fourth file.
          (this can be useful when you are trying to fail as early as
          possible by running integration-like tests first for whatever
          reason, assuming you structured your tree in the conventional way.)
        HERE
      end

      def initialize adapter

        @_adapter = adapter
        @_switch = adapter.build_required_arg_switch FLAG__
      end

      def opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end

      FLAG__ = '-order'.freeze

      ARGS_MONIKER__ = "#{ FLAG__ }=M-N"

      def desc y
        y << "(use \"#{ _flag }=help\")"
      end

      def prepare sig

        idx = @_switch.any_first_index_in_input sig
        if idx

          @_index = idx
          @_request = sig

          ___via_index_prepare  # result is sig
        else
          NIL_
        end
      end

      def ___via_index_prepare

        s = @_request.input[ @_index ][ @_switch.s.length + 1 .. -1 ]

        if s.length.zero?

          __when_flag_does_not_have_an_argument

        elsif 'help' == s
          __when_help

        else

          @_argument_string = s
          __via_argument_string
        end
      end

      def __when_flag_does_not_have_an_argument

        _y << "#{ _flag } must have an argument"
        NIL_
      end

      # -- Parse --

      def __via_argument_string

        _ok = ___omg
        _ok && __via_terms
      end

      def ___omg   # literally the worst

        dash = /-/
        dash_s = '-'

        n = /n/i
        n_s = "N"

        digit = /[0-9]+/

        scn = Home_::Library_::StringScanner.new @_argument_string
        @_strscan = scn

        parse_end = -> do
          if scn.eos?
            ACHIEVED_
          else
            _expecting
          end
        end

        after_digit_and_dash = -> do

          if scn.eos?
            _expecting n_s

          elsif scn.skip n
            _accept :N
            parse_end[]

          else
            s = scn.scan digit
            if s
              _accept :digit, s.to_i
              parse_end[]
            else
              _expecting :digit, n_s
            end
          end
        end

        after_N_and_dash = -> do

          if scn.eos?
            _expecting :digit

          else
            s = scn.scan digit
            if s
              _accept :digit, s.to_i
              parse_end[]
            else
              _expecting :digit
            end
          end
        end

        parse_nothing_or_dash_then = -> p do
          if scn.eos?
            ACHIEVED_
          elsif scn.skip dash
            p[]
          else
            _expecting dash_s
          end
        end

        @_terms = []

        s = scn.scan digit
        if s
          _accept :digit, s.to_i
          parse_nothing_or_dash_then[ after_digit_and_dash ]

        elsif scn.skip n

          _accept :N
          parse_nothing_or_dash_then[ after_N_and_dash ]

        else
          _expecting :digit, n_s
        end
      end

      def _accept sym, * rest
        a = @_terms
        if rest.length.zero?
          a.push sym
        else
          a.push Callback_::Pair.via_value_and_name( * rest, sym )
        end
        NIL_
      end

      def _expecting * x_a

        _exp_s = if x_a.length.zero?
          'nothing'
        else
          _s_a = x_a.map do | x |
            if x.respond_to? :id2name
              "<#{ x }>"
            else
              x.inspect
            end
          end
          Callback_::Oxford_or[ _s_a ]
        end

        scn = @_strscan

        _prep = if scn.eos?
          "at end of input"
        else
          "for #{ scn.rest.inspect }"
        end

        _y << "expecting #{ _exp_s } #{ _prep }"

        UNABLE_
      end

      def __via_terms

        sig = @_request
        sig.nilify_input_element_at_index @_index
        sig.carry :TEST_FILES, :CULLED_TEST_FILES
        sig
      end

      # -- Main --

      def test_files_eventpoint_notify

        ___init_ordered_paths
        ok = __normalize_as_counting_numbers
        ok && __init_range
        ok && __via_ordered_paths
      end

      def ___init_ordered_paths

        mutate = -> node do

          pairs = node.to_pair_stream.to_a

          pairs.sort_by! do | pair |
            Comparator___.new pair
          end

          _new_order_ = pairs.map( & :name_x )

          node.a_.replace _new_order_

          NIL_
        end

        orig_paths = @_adapter.services.get_test_path_array

        tree = Home_.lib_.basic::Tree.via :paths, orig_paths

        tree.accept do | node |

          if 1 < node.children_count

            mutate[ node ]
          end

          NIL_
        end

        _st = tree.to_stream_of :paths, :do_branches, false

        new_paths = _st.to_a

        if orig_paths.length != new_paths.length
          self._SANITY_lost_or_gained_paths
        end

        @_ordered_paths = new_paths
        NIL_
      end

      class Comparator___  # for use in sort_by!

        def initialize pair

          @has_children =  pair.value_x.has_children

          md = RX___.match pair.name_x
          s = md[ :digits ]
          if s
            @has_digits = true
            @d = s.to_i
            @s = md[ :rest ]
          else
            @has_digits = false
            @s = md[ :rest ]
          end
        end

        RX___ = /\A(?<digits>[0-9]+)?(?<rest>.*)\z/

        def <=> otr

          if otr.has_children
            if @has_children
              _when_in_same_primary_group otr
            else
              -1  # I have no children and you do. I come first.
            end
          elsif @has_children
            1  # I have children and you don't. You come first.
          else
            _when_in_same_primary_group otr  # neither of us have children
          end
        end

        def _when_in_same_primary_group otr

          # we both either do or don't have children

          if otr.has_digits
            if @has_digits
              d = @d <=> otr.d  # we both have digits. let's compare them.
              if d.zero?
                @s <=> otr.s  # our digits are the same. let's compare strings
              else
                d
              end
            else
              1  # you have digits and I don't. You come first.
            end
          elsif @has_digits
            -1  # I have digits and you don't. I come first.
          else
            @s <=> otr.s  # neither of us have digits. let's compare strings.
          end
        end

        a = [
          :d,
          :has_children,
          :has_digits,
          :s,
        ]
        attr_reader( * a )
        protected( * a )
      end

      def __normalize_as_counting_numbers

        a = []
        p = -> t { a.push t }
        h = [ p, p ]

        remove_instance_variable( :@_terms ).each_with_index do | t, d |
          h.fetch( d )[ t ]
        end

        len = @_ordered_paths.length

        a.each_with_index do | x, d |
          if :N == x.to_sym
            a[ d ] = Callback_::Pair.via_value_and_name( len, :digit )
          end
        end

        first_term = a.fetch 0
        second_term = a[ 1 ]

        @_len = len
        ok = true
        val_a = [ [ :first, first_term.value_x ] ]
        if second_term
          val_a.push [ :second, second_term.value_x ]
        end

        val_a.each do | sym, d |
          if 1 > d
            ok = ___too_low d, sym
            break
          end
          if len < d
            ok = __too_high d, sym
            break
          end
        end
        if ok
          @_terms = a
          ACHIEVED_
        else
          ok
        end
      end

      def ___too_low d, sym
        _y << "#{ sym } term cannot be #{ d }. must be at least 1."
        UNABLE_
      end

      def __too_high d, sym
        _y << "#{ sym } term cannot be greater than #{ @_len }. (had #{ d }.)"
        UNABLE_
      end

      def __init_range

        a = remove_instance_variable :@_terms
        first_term, second_term = a

        if second_term
          if second_term.value_x < first_term.value_x
            do_reverse = true
            a.reverse!
          end
        else
          a.push first_term.dup
        end

        begin_, end_ = a.map do | term |
          term.value_x - 1  # go from ordinal to
        end

        @_range = begin_ .. end_
        @_do_reverse = do_reverse
        NIL_
      end

      def __via_ordered_paths

        slice = @_ordered_paths[ @_range ]
        if @_do_reverse
          slice.reverse!
        end
        @_adapter.replace_test_path_s_a slice  # result is result
      end

      # -- Help --

      def __when_help

        st = __help_paragraph_stream
        y = _y
        para_s = st.gets
        if para_s
          y << para_s
          begin
            para_s = st.gets
            para_s or break
            y << nil
            y << para_s
            redo
          end while nil
        end

        sig = @_request

        sig.nilify_input_element_at_index @_index
        sig.carry :BEGINNING, :FINISHED

        sig
      end

      def beginning_eventpoint_notify
        # (when help)
        NIL_
      end

      def __help_paragraph_stream

        flag = flag

        scn = Home_::Library_::StringScanner.new __big_string

        body_rx = /(?:[^\n]|\n(?!\n)+)+\n?/
        skip_rx = /\n/

        p = -> do
          s = scn.scan( body_rx ) or fail
          d = scn.skip( skip_rx )
          if ! d
            p = EMPTY_P_
          end
          s
        end

        Callback_.stream do
          p[]
        end
      end

      def _y
        @_adapter.y
      end

      def _flag
        FLAG__
      end
    end
  end
end
