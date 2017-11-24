# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::String_via_Collection < Common_::MagneticBySimpleModel

    # the "collection" location map structure covers a wide variety
    # of grammar symbols, from literal strings to literal arrays up to
    # code blocks. generally (but not always) these features have a
    # beginning "delimiter" and an ending one..

    # "escaping theory" is the code-brunt of this file:
    #
    #   1) we recognize a special category of grammar symbols we call
    #      "string-ish terminals". by our definition here, this category
    #      is those terminals that need knowledge of the correct "escaping
    #      policy" to use for "optimistic unparsing". this category includes
    #      every kind of literal string, symbol, regexp, and perhaps others.
    #
    #   2) there is only ever exactly one correct escaping policy for a
    #      given terminal component. corollary: even when escaping is not
    #      employed (think `%w( foo bar )`) we use The Empty Policy for this.
    #
    #   3) in our current take, the escaping policy is determined exactly by
    #      a relevant opening delimiter. consider for example how the
    #      escaping policy differs for a single-quoted string vs. a double-
    #      quoted string. in our model, whether the opening delimiter is a
    #      single quote, a double quote (or other, there are many others)
    #      determines the escaping policy to use for expressing the content
    #      parts.
    #
    #      (policies can exist one-to-many with delimiters; i.e, different
    #      delimiters can share the same policy. perhaps not relevant here.)
    #
    #   4) there are two kinds of "reign" than an escaping policy can have.
    #      one is what we'll call "close reign", and the other "send-down
    #      reign". "close reign" is where the policy only holds while we
    #      are in the current structured node and its terminal components,
    #      not when we recurse into its any structured child nodes.
    #      a `str` is this way.
    #
    #   5) "send-down reign" is when we need the policy to inherit downwards
    #      (currently only ever one level) to its children..
    #      a `dstr` is this way..
    #
    #   :#spot2.2. more at #spot2.3
    # -

      def location= loc  # #cp/m
        @location_begin = loc.begin
        @location_end = loc.end
        @location_expression = loc.expression ; nil
      end

      attr_writer(
        :context_by,
        :buffers,
        :structured_node,
      )

      -> do

        common_asc = :zero_or_more_expressions
        common_assume = :assume_delimiters

        THESE___ = {

          # -- sender downers (see also terminals)

          dstr: {
            plural_association: :zero_or_more_dynamic_expressions,
            delimiter_expectations: common_assume,
            escape_policy_reign: :send_down,
          },

          regexp: {
            plural_association: common_asc,
            delimiter_expectations: common_assume,
            escape_policy_reign: :send_down,
            after_end: :__regexp_options_thing,
          },

          # -- highly customized

          block: {
            before_beginning: :__block_before_beginning,
            before_middle: :__block_before_middle,
            write_middle_by: :__block_during_middle,
            delimiter_expectations: common_assume,
          },

          # -- maybe sorta ordinary

          args: {
            plural_association: :zero_or_more_argfellows,
            delimiter_expectations: :neither_or_both,  # when '|' used as block delims
          },

          array: {
            before_middle: :__array_if_percenty_hugger_send_down_delimiter,
            plural_association: common_asc,
            delimiter_expectations: common_assume,
          },

          begin: {
            plural_association: common_asc,
            delimiter_expectations: :neither_or_both,
          },

          hash: {
            plural_association: :zero_or_more_pairs,
            delimiter_expectations: :neither_or_both,  # neither: #coverpoint6.3 (see)
            escape_policy_reign: :send_down,  # #coverpoint6.3 (see)
            default_delimiter: :__default_delimiter_for_hash,
          },

          mlhs: {
            plural_association: :one_or_more_assignableformlhss,
            delimiter_expectations: common_assume,
          },

          # -- terminals

          str: {
            terminal_shape: :string_shaped_terminal,
            terminal_method_name: :as_string,
            delimiter_expectations: :neither_or_both,  # neither: #coverpoint5.4
          },

          sym: {
            terminal_shape: :symbol_shaped_terminal,
            terminal_method_name: :as_symbol,
            delimiter_expectations: :neither_or_begin_and_maybe_end,
            # NOTE - escaping policy comes from either itself (`:foo`)
            # or from a parent (`:"{ 'like' } this"` or a hash)
          }
        }
      end.call

      def execute
        @node_type = @structured_node._node_type_
        @_mode = THESE___.fetch @node_type
        __init_escaping_responsibility
        @_opening_delimiter = nil
          __execute_normally
      end

      def __init_escaping_responsibility
        sym = @_mode[ :escape_policy_reign ]
        if sym
          case sym
          when :send_down
            yes = true
          else ; no
          end
        end
        @_do_send_down_delimiter = yes
      end

      # --

      def __block_before_beginning

        # form one is a classic block (`frob` is a method name) (#coverpoint3.9):
        #
        #     frob do |em|
        #     end
        #
        # form two is this stabby, procy arrangement (#coverpoint5.6):
        #
        #     -> arg1, arg2 do
        #     end
        #
        # these two forms are structurally different in terms of where the
        # arguments are expressed relative to the beginning run.
        #
        # firstly, each form has what we call a "blockhead". in the first,
        # the blockhead is `frob` (the name of the method being called). in
        # the second, the blockhead is the keyword `->`. in both forms, the
        # blockhead is the frontmost component that needs expressing.
        #
        # but then note how the two forms diverge structurally from here:
        # both forms have a `do` keyword (reached here by
        # `@location_begin.source`) AND both forms have args BUT
        #
        #     form one: BLOCKHEAD BEGIN ARGS ANY_BODY END
        #     form two: BLOCKHEAD ARGS BEGIN ANY_BODY END
        #
        # we determine which is which (perhaps hackishly) simply by looking
        # at the `begin_pos` location and cetera

        @buffers.recurse_into_structured_node @structured_node.blockhead  # `frob`, `->`

        # now, do we need to express args now or later?

        do_d = @location_begin.begin_pos

        expr_vr = _block_args_component._node_location_.expression

        _way = if expr_vr
          _args_d = expr_vr.begin_pos
          case do_d <=> _args_d
          when -1 ; :form_one
          when  1 ; :form_two
          else    ; no
          end
        else
          :no_args
        end

        case _way
        when :form_one

          # write the space between `frob` and `do`

          @buffers.write_as_is_to_here do_d
          @_block_before_middle = :__block_before_middle_form_2

        when :form_two

          _block_express_args_now
          # then write the space between `arg2` and `do`
          @buffers.write_as_is_to_here do_d

          # when it comes times for this, cha cha:
          @_block_before_middle = :_nothing

        when :no_args

          # like above, but no args.. #coverpoint6.2
          @buffers.write_as_is_to_here do_d
          @_block_before_middle = :_nothing

        else ; no
        end
        NIL
      end

      def __block_before_middle
        send @_block_before_middle
      end

      def __block_before_middle_form_2
        _block_express_args_now
        NIL
      end

      def _block_express_args_now
        @buffers.recurse_into_structured_node _block_args_component
        NIL
      end

      def _block_args_component
        @structured_node.args
      end

      def __block_during_middle  # look for patterns - is this really the only thing?

        sn = @structured_node.any_body_expression
        if sn
          @buffers.recurse_into_structured_node sn  # #coverpoint6.1
        end

        @buffers.write_as_is_to_here @location_end.begin_pos
        NIL
      end

      def __regexp_options_thing  # #coverpoint4.4

        # (even when there's no regexp opts there's a component and
        #  a location map pointing to a zero-width range so meh..)

        @buffers.recurse_into_structured_node @structured_node.regexopt
        NIL
      end

      def __array_if_percenty_hugger_send_down_delimiter

        # an array delimiter of `[` does not confer downward an escaping
        # policy, but the below kinds do..

        if :percenty_hugger == @_opening_delimiter.delimiter_category_symbol

          case @_opening_delimiter.delimiter_subcategory_value
          when :word_list
            # if the literal is `%w( one of these )`, then the expression of
            # the terminals (the words) requires knowledge of the delimiter.
            # (even though they don't employ escaping, they still require (2)
            # a policy because they are string-ish terminals.)

            yes = true  # #coverpoint5.4
          when :symbol_list
            yes = true  # #coverpoint6.5
          else ; no end
        end

        if yes
          @_do_send_down_delimiter = true
        end
      end

      # --

      def __execute_normally

        case @_mode.fetch :delimiter_expectations

        when :assume_delimiters
          both_OK = true

        when :neither_or_both
          both_OK = true
          neither_OK = true

        when :assume_no_delimiters
          # ..

        when :neither_or_begin_and_maybe_end
          begin_and_no_end_OK = true
          both_OK = true
          neither_OK = true

        else ; no end

        # in some literal features you may need to write the spaces between
        # the items, like in `%w( foo bar )` or the leading separator space
        # before the literal. (#coverpoint4.3 exhibits both, 3x total times)

        ra = @location_expression
        if ra
          @buffers.write_as_is_to_here ra.begin_pos
        else
          _nothing  # #coverpoint4.2
        end

        __before_beginning

        if @location_begin
          if @location_end
            both_OK || sanity  # LOOK begin and maybe end
            _write_the_beginning
            _write_the_middle
            _write_the_end
          else
            begin_and_no_end_OK || sanity  # #coverpoint3.5 (ideal literal symbols)
            _write_the_beginning
            _write_the_middle
          end
        elsif @location_end
          sanity  # we never encounter an end but no beginning in nature
        else
          if ! neither_OK
            reality_defies_expectation
          end
          __init_default_delimiter_if_necessary
          _write_the_middle
        end
        __after_end
      end

      def _write_the_beginning

        d = @location_begin.end_pos

        quot = @buffers[ @location_begin.begin_pos ... d ]

        @buffers.write quot, d

        begin
        @_opening_delimiter = CrazyTownUnparseMagnetics_::Delimiter_via_String[ quot, @node_type ]
        rescue COVER_ME => e
        end

        if e
          byebug_chillin ; exit 0
        end

        NIL
      end

      def __init_default_delimiter_if_necessary  # call this IFF no opening delimiter

        # for example if a hash
        if @_do_send_down_delimiter
          @_opening_delimiter && sanity
          @_opening_delimiter = send @_mode.fetch :default_delimiter
          NIL
        end
      end

      def __default_delimiter_for_hash
        Home_::CrazyTownUnparseMagnetics_::Delimiter_via_String::Default_delimiter_for_hash[]
      end

      def _write_the_middle

        __before_middle

        m = @_mode[ :write_middle_by ]
        if m
          send m
        elsif @_mode[ :terminal_method_name ]
          __write_the_middle_terminally
        else
          __write_the_middle_normally
        end
      end

      def __before_middle
        m = @_mode[ :before_middle ]
        if m
          send m
        end
      end

      def __write_the_middle_normally

        if @_do_send_down_delimiter
          delim = remove_instance_variable :@_opening_delimiter
          context_by = -> { delim }
        end

        _m = @_mode.fetch :plural_association
        _list_like = @structured_node.send _m

        @buffers.recurse_into_listlike context_by, _list_like

        NIL
      end

      def __write_the_middle_terminally

        # every terminal *must* know it's delimiter (and it must have one),
        # even the child `str` of a `dstr`..

        # whether or not the below ivar is set is directly related to
        # whether or not we parsed our own delimiter here

        delim = remove_instance_variable :@_opening_delimiter
        if ! delim
          # #coverpoint5.1 #coverpoint5.4 #coverpoint6.3
          _p = remove_instance_variable :@context_by
          if ! _p
            byebug_chillin ; exit 0
          end
          delim = _p[]
        end

        le = @location_end
        _d = if le
          le.begin_pos
        else
          @location_expression.end_pos  # #coverpoint5.4
        end

        _m = @_mode.fetch :terminal_method_name
        _x = @structured_node.send _m

        Home_::CrazyTownUnparseMagnetics_::String_via_StringishLiteral.call_by do |o|
          o.terminal_value = _x
          o.terminal_shape = @_mode.fetch :terminal_shape
          o.opening_delimiter = delim
          o.content_end_pos = _d
          o.buffers = @buffers
        end
      end

      def _write_the_end  # #coverpoint3.5
        vr = @location_end
        if vr.begin_pos != @buffers.pos
          _nothing  # #coverpoint4.3
        end
        @buffers.write_as_is_to_here vr.end_pos
      end

      def __before_beginning
        m = @_mode[ :before_beginning ]
        if m
          send m
        end
      end

      def __after_end
        m = @_mode[ :after_end ]
        if m
          send m
        end
      end

      def _nothing
        NOTHING_
      end

      def _DS
        @buffers._DS
      end

      def _SN  # #TODO
        @structured_node
      end
    # -
    # ==

    # ==
    # ==
  end
end
# #abstracted.
