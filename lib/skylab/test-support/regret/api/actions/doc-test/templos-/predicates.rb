class Skylab::TestSupport::Regret::API::Actions::DocTest

  module Templos_::Predicates

    # whether or not the line was processed should not be isomorphic with
    # whether or not any lines were outputted. hence the true-ish/false-ish
    # ness of our result reflects whether we did or did not match,
    # respectively.
    #
    # downwards because the nodes are for now private to this node, we
    # can implement them as simple functions, and spare ourselves the
    # cognitive overhead.

    def self.lines y, line, &otherwise
      idx = line.index SEP ; matched = nil
      if idx  # magic separator hack: "# =>" becomes:
        lef = line[ 0 .. idx - 1 ].strip
        rig = line[ idx + SEP.length .. -1 ].strip
        matched = constants.reduce nil do |_, i|
          # ( module as switch statement [#ba-018] )
          const_get( i, false ).call y, lef, rig and break true
        end
      end
      if matched then matched else
        otherwise.call
      end
    end
  end

  Templos_::Predicates::Should_Raise_ = -> do
    # e.g "NoMethodError: undefined method `wat` .."
    hack_rx = /\A[ ]*
      (?<const>[A-Z][A-Za-z0-9_]{6,}) [ ]* : [ ]*
      (?:
        (?<fullmsg> .+ [^.] \.?   ) |
        (?: (?<msgfrag> .* [^. ] ) [ ]* \.{2,} )
      ) \z
    /x
    # (the shortest ruby builtin exception class name is 7 chars long ick.)

    -> y, lef, rig do
      hack_rx.match rig do |md|
        const, fullmsg, msgfrag = md.captures
        _rx = if fullmsg
          "\\A#{ ::Regexp.escape fullmsg }\\z".inspect
        else
          "\\A#{ ::Regexp.escape msgfrag }".inspect
        end
        y << '-> do'
        y << "  #{ lef }"
        y << "end.should raise_error( #{ const },"
        y << "             ::Regexp.new( #{ _rx } ) )"
        true  # important
      end
    end
  end.call

  Templos_::Predicates::Should_Eql_ = -> y, lef, rig do
    y << "#{ lef }.should eql( #{ rig } )"
    true
  end
end
