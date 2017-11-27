# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::String_via_StringishLiteral < Common_::MagneticBySimpleModel

    # expressing string-like features back to into a file is particular if
    # it involves escaping. our concept of "stringish literals" includes:
    #
    #   - single quoted strings
    #   - double quoted strings
    #   - regexp bodies
    #   - literal lists of strings `%w( foo bar )`

    # it does NOT however include:
    #   - heredocs per se (for reasons) (but their constituent lines are)

    # this category of features we define broadly involves one or more of
    # these concerns: maybe some kind of opening delimiter, maybe some body,
    # maybe some closing delimiter. to express the body either does or
    # doesn't require some escape-encoding. when it does, there is a
    # discrete, comprehensive set of characters that are escaped, depending.
    # (more at #spot2.1 "optimisic escaping" and #spot2.2 "escaping theory",
    # and #spot2.3 "why parsing delimiters is complicated")

    # *all* opening & closing delimiters are now expressed in a certain elsewhere

    # -

      attr_writer(
        :terminal_value,
        :terminal_shape,
        :opening_delimiter,
        :content_end_pos,
        :buffers,
      )

      -> do

        # (regexen like below are tracked with #[#ba-029.2])

        same_double_quote = {
          escaping_regexp: /["\\\n\t\r\e\b]/,
        }

        same_single_quote = {
          escape_method: :__for_single_quote_do_special_escaping_logic,  # (see)
        }

        THESE___ = {

          singleton_delimiter: {

            FORWARD_SLASH_ => {
              escaping_regexp_method: :_custom_escapey_regexp_for_regexp,
            },

            DOUBLE_QUOTE_ => same_double_quote,  # #coverpoint4.5

            SINGLE_QUOTE_ => same_single_quote,

          },
          symbol_looks_like_double_quoted_string: same_double_quote,

          symbol_looks_like_single_quoted_string: same_single_quote,  # #coverpoint.NOT_COVERED

          pretend_delimiter_for_heredoc: {  # #coverpoint5.1
            escaping_regexp: /[\\\t\e\b]/,  # LOOK you don't escape newlines
          },

          percenty_hugger: {

            word_list: {
              escaping_regexp_method: :__custom_escapey_regexp_for_word_list,
            },

            symbol_list: {
              escaping_regexp_method: :__custom_escapey_regexp_for_symbol_list,
            },

            specially_delimited_regexp: {
              escaping_regexp_method: :_custom_escapey_regexp_for_regexp,
            },

            string_fellow: {
              escaping_regexp_method: :__custom_escapey_regexp_for_string,
            },
          },

          hash_open_curly_bracket: {
            escaping_regexp_method: :__custom_escapey_regexp_for_inside_hash,
          },

          ideal_literal_symbol: {
            escaping_regexp_method: :__custom_escapey_regexp_for_ideal_literal_symbol,
          },
        }
      end.call

      def execute

        # using a regex appropriate for the kind of delimiter in use, search
        # the mixed string ("mixed" meaning it could contain any characters)
        # for any characters that need escaping. lazily only once you find
        # any, fire up our escaping machinery. this is fallible; see #spot2.1.

        x = remove_instance_variable :@terminal_value

        case @terminal_shape
        when :symbol_shaped_terminal
          deep_s = x.id2name  # #coverpoint3.5
        when :string_shaped_terminal
          deep_s = x
        else ; no end

        __resolve_mode

        _use_s = __optimistic_idiomatic_escaped_string_via__deep_string deep_s

        __write_surface_form_of_literal_content _use_s, @content_end_pos
      end

      def __optimistic_idiomatic_escaped_string_via__deep_string deep_s

        m = @_behavior[ :escape_method ]
        if m
          send m, deep_s
        else
          rx = __flush_regexp
          if rx
            deep_s.gsub rx do |s|
              Escaping_policy___[][ s ]
            end
          else
            deep_s  # #coverpoint4.8 (and others)
          end
        end
      end

      def __flush_regexp

        rx = @_behavior[ :escaping_regexp ]
        if rx
          rx
        else
          _m = @_behavior.fetch :escaping_regexp_method
          send _m
        end
      end

      def _custom_escapey_regexp_for_regexp  # #coverpoint5.5

        # :[#007.R]: our initial stab at this involved custom-tailoring an
        # escaping regexp to accord to whatever delimiting character would
        # need to be escaped. e.g if the regexp was like `%r(xxx)` and the
        # deep string was like "ab)c" then the file bytes should be
        # `%r(ab\)c)`.
        #
        # (point of history: it was this: `%r([/\n\t\r\b])`)
        #
        # but what we initially refactored this to was based on what would
        # prove to be (variously) one faulty premise and one point that is
        # now not yet fully understood #todo.
        #
        # first, one faulty premise was that the file bytes of a regexp
        # string are internalized to a deep string mostly like the file
        # bytes of a double-quoted string are.
        #
        # so:
        #     s = "foo\nbar"
        #     rx = /foo\nbar/
        #
        # this does not prove the point (because we are not demonstrating
        # how the vendor lib parses the above literals into AST's) but:
        #
        #     puts s  # 2 lines
        #     puts rx.source  # 1 line
        #
        # that is, the "deep bytes" of the regexp are the same as the file
        # bytes. this appears to hold for all backslash expressions we've
        # tried (but we have not sampled this exhaustively). this is to say
        # that regexp file bytes are *not* interpreted just like double-
        # quoted strings (but note that both support `#{}` escaped sub-
        # expressions alla `dstr`). so that's one.
        #
        # the other (less understood) point is the crazy way that regexp
        # expression interpretation is parenthesis aware. so you can chose
        # any kind of "hugging" pair to follow `%r`, like `%r<^foo$>`, etc.
        #
        # consider these:
        #
        #     rx1 = %r[[abc]]
        #     rx2 = %r(foo (bar|baz))
        #
        # in the first one, you would not be remiss to ask why we chose `[]`
        # as our hugging delimiter if the regexp also contains `[]` as a
        # character class expression. but anyway, realize that in order for
        # the interpreter to find the ending regexp delimiter, it has to keep
        # track (probably with a stack) of whether these other sub-expressions
        # are opened or closed. SO if you're using (say) `()` as your hugging
        # delimiter and you want to have a `)` *in* your regexp, whether or
        # not you escape it with a backslash depends on whether or not
        # (EDIT: #open [#007.T] documentation hole)
        #
        # what all of this musing leads us to is this one axiom: for now,
        # for better or worse we do NOT escape ANYHING when producing file
        # bytes for regexps. we are almost certain this will be broken for
        # some guys, but we think it will pass our corpus for now ..

        NOTHING_
      end

      def __custom_escapey_regexp_for_string  # #coverpoint4.7
        _s = __be_careful
        /[\\\n\r\t\b#{ _s }]/
      end

      def __custom_escapey_regexp_for_word_list
        NOTHING_  # #coverpoint4.3
      end

      def __custom_escapey_regexp_for_symbol_list
        NOTHING_  # #coverpoint6.5
      end

      def __custom_escapey_regexp_for_inside_hash
        NOTHING_  # #coverpoint6.3
      end

      def __for_single_quote_do_special_escaping_logic deep_s  # #coverpoint4.6

        # we used to use this regexp for our escape policy for single-
        # quoted strings:
        #
        #     /['\\]/
        #
        # that is, for any single quote or backslash, when you're
        # expressing it as "file bytes", escape it with a backslash.
        #
        # although the above works, it does not in produce idiomatic file
        # bytes and so "corrupts" our files by normalizing our strings in a
        # manner we do not want.
        #
        # to understand why takes a bit of explanation, and has to do with
        # the ruby specification for interpreting literal strings:
        #
        #   puts "\d"  # => d
        #   puts '\d'  # => \d
        #
        # imagine you're deciding on the the specification for ruby single-
        # quoted strings. you say "well what if i want my single-quoted
        # string to itself have a single quote?". the idiomatic solution
        # (and the one employed) is to specify backslash-single-quote as
        # an escape sequence for this.
        #
        # but then the question becomes "what if i want to have a literal
        # backslash and then a single quote *in* my string?". this of course
        # requires the use of a backslash-backslash. (if you want two literal
        # backslashes in your string, your file bytes need to have four,
        # and so on.)
        #
        # (presumably) because more than one slash or backslash in a row is
        # sub-optimal for the human eye to read ("LTS - leaning toothpick
        # syndrome"); matz or whoever decided to add a loophole to the rules
        # so that writing strings could Just Work for many more cases
        # without incurring LTS.
        #
        # the loophole is that if your would-be escape sequence is not a
        # recognized escape sequence for *single* quoted strings; then your
        # backslash will be passed thru as-is as a literal backslash:
        #
        #     '\n'.length  # => 2
        #
        # (note this loophole does *not* exist for *double*-quoted strings
        # and related; probably because there are relatively many escape
        # sequences supported there, so to have this loophole there would
        # make those strings *less* readable because of how much a priori
        # knowledge you would need to read strings and know whether or not
        # something that looks like an escape sequence is one or not. whew!)
        #
        # if you're still following this, this means that in order to
        # produce idiomatic literal single-quoted strings, what we actually
        # want is something like this:
        #
        #   - single quote? escape it.
        #   - backslash?
        #     - is there a character after it?
        #       - no? pass the backslash thru as is.
        #       - yes: is the *following* character a backslash or a single quote?
        #         - yes? escape *this* backslash with another backslash.
        #         - no: PASS THE BACKSLASH THRU AS IS

        # (this *could* be done with only a killer regexp but we want the
        # logic to be more trackable..)

        deep_s.gsub %r('|\\((?=.)?)) do
          s = $~[1]
          if s
            _yes = case s
            when BACKSLASH_ ; true
            when SINGLE_QUOTE_ ; true
            end
            if _yes
              '\\\\'
            else
              BACKSLASH_
            end
          else
            %q(\')
          end
        end
      end

      def __custom_escapey_regexp_for_ideal_literal_symbol
        # an "ideal literal symbol" is one `:like_this` where you don't have
        # to do any escaping #coverpoint3.5
        NOTHING_
      end

      def __be_careful
        s = @opening_delimiter.closing_delimiter_character
        s || sanity
        if ']' == s
          '\\]'
        else
          s
        end
      end

      def __write_surface_form_of_literal_content encoded_s, end_pos

        current_s = @buffers[ @buffers.pos ... end_pos ]

        if current_s != encoded_s
          investigate ; exit 0
          self._COVER_ME__better_escaping_logic_might_be_necessary__
        end

        @buffers.write encoded_s, end_pos
      end

      def __resolve_mode
        delim = @opening_delimiter
        cat = THESE___.fetch delim.delimiter_category_symbol
        x = delim.delimiter_subcategory_value
        @_behavior = if x
          cat.fetch x
        else
          cat  # meh..
        end
        NIL
      end
    # -

    # -
    # ==

    Escaping_policy___ = Lazy_.call do

      # (this is written to cover all types of escapes, but the client must narrow it)

      Home_.lib_.basic::String::CharacterEscapingPolicy.define do |o, so|

        same = so.escape_it_with_a_backslash

        o.double_quote = same
        o.single_quote = same
        o.newline = so.use_this_string_instead '\n'
        o.backslash = same
        o.tab = so.use_this_string_instead '\t'
        o.forward_slash = same
        o.ASCII_escape = so.use_this_string_instead '\e'
        o.alert_bell = nil  # contact. hi.

        o.default_by  # hi.
          # see [#007.R] about regexp escaping. we once wanted this. now, no

      end
    end

    # ==

    BACKSLASH_ = '\\'

    # ==
    # ==

    # "optimistic" escaping :#spot2.1:

    # the vendor library (reasonably) hands us a real-life string that
    # looks like the literal string being represented. imagine this in
    # the case of a single-quoted literal string "ed's id" that in code
    # is written delimited by single quotes and so looks like:
    #
    #     'ed\'s id'
    # so:
    #
    #   - the string this literal expression represents ("ed's id") is
    #     (um) 7 characters wide.
    #
    #   - the representation of this literal expression in the source
    #     (file) (not counting the bounding single quotes) is *8*
    #     characters wide. (the backslash takes up a character).
    #
    #   - so how many characters are in the string in the parse tree?
    #
    # the answer is 7 - so the string that the vendor lib hands us is
    # like the real string being expressed, not the way it happens to
    # be represented in the source file.
    #
    # this seems appropriate - but note that when re-writing the file with
    # new content we are going from a deep representation to a surface
    # representation. to the extent that there's multiple surface ways
    # to express the same deep meaning (and there are), when going from
    # deep to surface, the process won't always be deterministic..

    # #open [#007.S]: one of many caveats with this approrach: this will
    # be broken if, say, you want to modify the contents of a single-quoted
    # string `'ed\'s bread'` by, say, getting a newline in there. what would
    # happen is that because the escaping policy for single-quoted strings
    # is being used, the newline will be converted to a file-byte AS-IS
    # and probably generate a syntactically invalid document. the fix for
    # this would be to change what kind of delmiters we use for the
    # generated in such cases, which while a fun exercise is currently way
    # out of scope.

    # more at #spot2.2
  end
end
# #abstracted.
