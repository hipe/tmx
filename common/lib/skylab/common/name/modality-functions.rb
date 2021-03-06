module Skylab::Common

  module Name::Modality_Functions  # see [#060]

    # this grain of sand is all that remains of our universe's first name
    # lib. at some point (and with reason) [cb] rewrote a name class from
    # scratch that we now use exclusively. the name of this topic node is
    # a tribute to the [cu] report allowing us to cull-out the still-used
    # the functions here & toss the rest of the now obviated legacy code.

    # #storypoint-10

      Labelize = -> do  # :+[#088]
        -> ivar_i do
          s = ivar_i.id2name
          Mutate_string_by_chomping_any_leading_at_character___[ s ]
          Mutate_string_by_chomping_any_trailing_name_convention_suffixes[ s ]
          s.gsub! UNDERSCORE_, SPACE_
          Ucfirst___[ s ]
        end
      end.call

      Mutate_string_by_chomping_any_leading_at_character___ = -> do
        rx = /\A@/
        -> s do
          s.sub! rx, EMPTY_S_ ; nil
        end
      end.call

      Mutate_string_by_chomping_any_trailing_name_convention_suffixes = -> do
        rx = /(?<=[a-z]{2}) (?:  (?:_[a-z])+_* | _+  )  \z/ix
        -> s do
          s.sub! rx, EMPTY_S_ ; nil
        end
      end.call

      Ucfirst___ = -> do
        rx = /\A[a-z]/
        -> s do
          s.sub rx, & :upcase
        end
      end.call

      Mod_moniker_via_num_parts_and_module___ = -> num_parts, mod do
        s_a = mod.name.split CONST_SEPARATOR
        _s_a_ = if ! num_parts then s_a
        elsif num_parts.respond_to? :cover?
          s_a[ num_parts ]
        elsif num_parts.zero?
          EMPTY_A_
        else
          s_a[ - num_parts .. -1 ]  # whether positive or negative
        end
        _s_a_.map do |s|
          Home_::Name.via_const_string( s ).as_human
        end * TERM_SEPARATOR_STRING_
      end

      Module_moniker = Mod_moniker_via_num_parts_and_module___.curry[ 1 ]

  end
end
# #tombstone Via_anchored_in_module_name_module_name
