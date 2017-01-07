module Skylab::Zerk::TestSupport

  class CLI::IndexOfSplay_via_Line < Home_::SimpleModel_

    # for our purposes here, a "splay" line is something like:
    #
    #     "waboozie foozie: fipple, dipple-doople, doppel or -flopple"
    #
    # or
    #     'weeple deople "dopple" - wotunda foopie "doop", "loop" or "koop"?"
    #
    # as far as we're concerned (and by default) such a line must contain:
    #
    #   - one nonzero-length string of "introductory text"
    #     (the part up to and including the first colon and its space).
    #     we don't assert any content here at all except for the above. THEN:
    #
    #   - a list of one or more "feature-tokens".
    #     a feature token corresponds to an operator or a primary
    #     (whether it begins with a dash determines which).
    #
    # as for stuctural validations we do,
    #
    #   - as far as we're concerned it is permissible to have overlap in
    #     the set of normal name (symbols) of the two sets - e.g you could
    #     have a primary "-foo-bar" and an operator "foo-bar" and this
    #     indexing will allow that.
    #
    #   - however if there's a repeat of the same name in any one set,
    #     this indexing will fail unobscurely.
    #
    # there are undocumented features with semi-obvious names below
    # to fine-tune the above expectations..

    class << self
      def call line
        define do |o|
          o.line = line
        end.execute
      end
      alias_method :[], :call
    end  # >>
    # -

      def initialize
        @head_regexp = nil
        yield self
        # can't freeze because memoizes details at waypoints
      end

      attr_writer(
        :head_regexp,
      )

      def line= line
        @_scn = Home_.lib_.string_scanner.new line
      end

      def execute
        __parse_introductory_head
        __parse_splay
        __finish
      end

      def __finish

        bx = remove_instance_variable :@_operators_box
        if bx
          @offset_via_operator_symbol = bx.h_.freeze
        end
        bx = remove_instance_variable :@_primaries_box
        if bx
          @offset_via_primary_symbol = bx.h_.freeze
        end

        @number_of_features =
          ( remove_instance_variable :@_offset_of_last_feature ) + 1

        remove_instance_variable :@_scn
        remove_instance_variable :@head_regexp
        freeze
      end

      def __parse_introductory_head

        _use_rx = @head_regexp || %r((?:(?!:[ ]).)+:[ ])
        s = @_scn.scan _use_rx
        s || fail
        @introductory_head = s.freeze
        if false  # code sketch
        content = s[ 0 .. -3 ]  # eek
        _words = content.split Home_::SPACE_
        end
      end

      def __parse_splay  # curates the assumption of at least one item

        @_offset_of_last_feature = -1
        @_operators_box = nil
        @_primaries_box = nil

        _parse_one_feature

        if ! _done
          scn = @_scn
          begin
            if scn.skip COMMA___
              _parse_one_feature
              redo
            end
            __parse_and_or_or
            break
          end while above
          _parse_one_feature

          if ! _done
            fail
          end
        end
        NIL
      end

      def _done
        if @_scn.eos?
          TRUE
        elsif @_scn.skip %r(\?)
          @ended_in_question_mark = true
          if @_scn.eos?
            TRUE
          else
            fail self.__SAY__encountered_question_mark_in_non_final_position
          end
        else
          FALSE
        end
      end

      def _parse_one_feature

        if @_scn.skip DASH___
          was_primary = true
        end
        s = @_scn.scan SLUG___
        s || fail
        _d = ( @_offset_of_last_feature += 1 )
        _sym = s.gsub( DASH_, UNDERSCORE_ ).intern

        ( if was_primary
          @_primaries_box ||= Common_::Box.new
        else
          @_operators_box ||= Common_::Box.new
        end ).add _sym, _d

        NIL
      end

      def __parse_and_or_or
        if @_scn.skip OR___
          @and_not_or = false
        elsif @_scn.skip AND___
          @and_not_or = true
        else
          fail
        end
      end

      attr_reader(
        :and_not_or,
        :introductory_head,
        :number_of_features,
        :offset_via_operator_symbol,
        :offset_via_primary_symbol,
      )
    # -

    # ==

    AND___ = / and /
    COMMA___ = /, /
    DASH___ = /-/
    OR___ = / or /
    SLUG___ = /[a-z][a-z0-9]*(?:-[a-z0-9]+)*/

    # ==
  end
end
# #born for new [tmx]
