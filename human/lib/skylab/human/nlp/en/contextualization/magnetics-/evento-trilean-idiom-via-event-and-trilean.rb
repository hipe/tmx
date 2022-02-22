module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Evento_Trilean_Idiom_via_Event_and_Trilean < Magnet_

      # the difference between "lexeme" and "lemma" (see any dictionary)
      # is significant here. (cheat: lemma is a bit like "class" and
      # lexeme "object" by massive stretch of analogy.) if we have a lexeme
      # then we also have inflectional information about how it is to be
      # expressed. however if we only have a lemma than we are free to
      # determine appropriate inflection ourselves. (this is not a hard fast
      # rule but a synopsis.)
      #
      # one main reason why event-related expression has so many dedicated
      # nodes on the pipeline is because the only way to get lexemes into
      # the session is through an event (a reliance on this arrangement is
      # an architectural smell, sure) and lexemes require special handling
      # because they are not just strings but mutable objects with their own
      # API.
      #
      # separate from this lexemo-eventular handling, we also have a smatter
      # of lemmato-eventular handling. at the moment you can acquire lemmas
      # via a subject association and/or selection stack. (if you have
      # neither lemma nor lexeme then you may think you have no need for
      # contextualization, but maybe you're trying to make an exception
      # from an event.) so, when events are also in this mix with *lemmas*
      # (not lexemes) then there are endemic linquistic patterns there
      # (namely, assuming that events express complete sentence-phrases so..)

      def execute

        event_x = @ps_.possibly_wrapped_event

        if event_x.respond_to? :inflected_verb
          _receive_event event_x.to_event
          __when_wrapped

        else
          _receive_event event_x

          if event_x.has_member :verb_lexeme
            _when_lexemic
          else
            __when_other
          end
        end
      end

      def _receive_event ev

        @_event = ev

        @_is_completion = ev.has_member( :is_completion ) && ev.is_completion

        # for now, we've got to always *overwrite* whatever trilean we got
        # from the channel (OR USER) with whatever is in the event (or change
        # the pipeline..) legacy apps expect the event and not channel to be
        # the determiner here. ([br] falls apart without this.) :#c15n-spot-2

        x = ev.ok
        @ps_.trilean = x
        @trilean = x

        NIL_
      end

      def __when_wrapped
        # (hi.)
        _when_lexemic
      end

      def _when_lexemic

        if @trilean
          if @_is_completion
            :Is_Lexemic_Frobbed_Colon
          else
            :Is_Lexemic_While_Frobbing
          end
        elsif @trilean.nil?
          if @_is_completion  # [br]
            :Is_Lexemic_Frobbed_Colon
          else
            x = @ps_.idiom_for_neutrality
            if x
              Const_via_idiom_[ x, @ps_ ]
            else
              :Is_Lexemic_While_Frobbing
            end
          end
        else
          :Is_Lexemic_Couldnt_Frob_Because
        end
      end

      def __when_other

        ps = @ps_
        ss = ps.selection_stack
        if ss
          nss = Magnetics_::Normal_Selection_Stack_via_Selection_Stack[ ps ]
          ps.normal_selection_stack = nss  # #open [#043]
          lemz = Magnetics_::Lemmas_via_Normal_Selection_Stack[ ps ]
          ps.lemmas = lemz  # #open [#043]
        else
          sa = ps.subject_association
          if sa
            lemz = Magnetics_::Lemmas_via_Subject_Association_XXX[ ps ]
            ps.lemmas = lemz
          end
        end

        # note - we go "lemmatic" even when there are no lemmas, just to minify this
        # every XXX below and above is #open [#053]

        if @trilean
          if @_is_completion
            :Is_Lemmatic_Completion_XXX
          else
            :Is_Add_Nothing
          end
        elsif @trilean.nil?
          if @_is_completion
            :Is_Lemmatic_Completion_XXX
          else
            x = @ps_.idiom_for_neutrality
            if x
              Const_via_idiom_[ x, @ps_ ]
            else
              :Is_Add_Nothing
            end
          end
        else
          :Is_Lemmatic_Failed_To_Frob
        end
      end
    end
  end
end
# #history: broke out of "expression via emission"
