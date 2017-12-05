module Skylab::Human

  ExpressionPipeline_::ConstString_via_TermScanner = -> do  # 2x. [here] only.

    # in "classical" autoloading the transition from const to filename is
    # "lossy" (described exactly at [#co-024.4]), i.e you cannot cleanly
    # infer `NCSA_Spy` from "ncsa-spy.rb". however over here we can afford
    # to make some assumptions that we can't make with general autoloading,
    # assumptions that free us from relying on facilities with more moving
    # parts that what we do below, to infer a const from a filename.
    #
    # if this file feels anemic, it's because our parent module is cleanly
    # a branch module; i.e everything under it needs to be in some purpose-
    # specific file, and nothing under it is loaded "for free".

    const_via_term_scanner_via_keywords = -> keywords do

      # (this is definitely somewhat redundant with something somewhere else)

      # generally:
      #
      #   a const-piece followed by const-piece: no interceding underscore
      #   a const-piece followed by a keyword: interceding underscore
      #   a keyword followed by a const piece: interceding underscore
      #   a keyword follwed by a keyword: not allowed

      # because of the assumption #here1, we assume that we only ever see
      # the ingredients of any particular const only ever once, so no caching.

      is_keyword = ::Hash[ keywords.map { |s| [ s, true ] } ]

      -> scn do  # assume more than one term in scanner and..

        term = scn.gets_one
        is_keyword[ term ] and self._COVER_ME__no__
        buffer = Ucfirst_[ term ]
        last_was_keyword = false

        begin

          term = scn.gets_one
          this_is_keyword = is_keyword[ term ]

          if this_is_keyword

            last_was_keyword && self._COVER_ME__cant_have_two_keywords_in_a_row__

            buffer << UNDERSCORE_ << term

          elsif last_was_keyword

            buffer << UNDERSCORE_ << Ucfirst_[ term ]

          else
            buffer << Ucfirst_[ term ]  # near `as_camelcase_const_string`
          end

          last_was_keyword = this_is_keyword  # used even outside of loop
        end until scn.no_unparsed_exists

        last_was_keyword && self._COVER_ME__doesnt_look_right_to_end_in_a_keyword__

        buffer
      end
    end

    const_via_term_scanner_via_keywords[ %w( via with and of ) ]
  end.call

  # -
end
# #history: broke out of sibling file
