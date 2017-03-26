module Skylab::Human

  module NLP::EN

    class Magnetics::Phraseish_via_AlreadyInflectedAtom

      class << self

        def interpret_component scn, _asc
          x = scn.gets_one
          if x
            via_ x
          else
            x  # life is easier to allow the client to pass nils
          end
        end

        def via_ x
          if x.respond_to? :ascii_only?
            Phraseish_via_String___.new x
          elsif x.respond_to? :id2name
            Phraseish_via_Symbol.new x
          else
            self._COVER_ME__shape_not_recognized__
          end
        end
      end  # >>

      # -

        def initialize(*)
          self._NEVER__assert_abstract_base_class__
        end

        def express_into_phrase_builder__ pb
          pb.add_string _as_string_
          NIL
        end

        def express_into_under y, _
          y << _as_string_
        end

        def _difference_against_counterpart_ x
          _inner_x_ != x._inner_x_
        end

        def _can_aggregate_
          true
        end
      # -
      # ==

      class Phraseish_via_String___ < self

        def initialize s
          @_string = s
        end

        def _as_string_
          @_string
        end

        def _inner_x_
          @_string
        end
      end

      # ==

      class Phraseish_via_Symbol < self  # outside this file 1x only ([here] only)

        def initialize sym
          @_symbol = sym
        end

        def _as_string_
          @_symbol.id2name
        end

        def _inner_x_
          @_symbol
        end
      end

      # ==
      # ==
    end
  end
end
# #history: broke stowaway out. code is just over a year older than file.
