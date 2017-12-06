module Skylab::Human

  module NLP::EN

    class Magnetics::Phraseish_via_AlreadyInflectedAtoms_in_Scanner  # 1x

      # express a list of words (passed within a scanner) simply by
      # separating them with a space

      class << self

        def interpret_component scn, asc
          new( asc ).__init_comp scn
        end

        def interpret_component_fully_ scn, asc
          new( asc ).__init_own scn
        end

        private :new
      end  # >>

      def initialize asc
        @_asc = asc
      end

      def __init_comp scn
        @_strings = scn.gets_one
        self
      end

      def __init_own scn
        @_strings = scn.gets_one
        scn.assert_empty
        self
      end

      # --

      def express_into_under y, _expag
        scn = Scanner_[ @_strings ]
        y << scn.gets_one
        until scn.no_unparsed_exists
          y << SPACE_
          y << scn.gets_one
        end
        y
      end

      # -- see [#050]:"note about aggregating word-lists"

      def _can_aggregate_
        true
      end

      def _difference_against_counterpart_ otr
        otr._strings != @_strings  # #equivalence
      end

      attr_reader :_strings  # #testpoint
      protected :_strings

      # ==
      # ==
    end
  end
end
# #history: broke stowaway out of main file. code is just under a older than file
