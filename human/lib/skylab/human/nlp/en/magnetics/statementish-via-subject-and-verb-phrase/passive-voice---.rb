module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Statementish::Passive_voice___

      # omg swtich to #passive-voice - this won't always be pretty:
      #
      #     "VOO requires FOO" => "FOO is required"
      #     "BOO had DOO"      => "DOO was had"

      # because this is a rough sketch we are knowingly taking a shortcut
      # that will produce sub-natural expressions: what we want is a past
      # participle but that grammatical category is not yet built into the
      # system (#wish [#055]). in its place we use the preterite which
      # a) accidentally works "most of the time" (because past participle
      # is regularly the same surface lemma as pereterite) and b) when it
      # is sub-natural it still conveys meaning sufficiently (e.g it would
      # say "was ate" for "was eaten", etc) and c) our lexical coverage for
      # irregular preterites is sub-natural anyway, so we would actually
      # get "was eated", which is amazing and still makes sense.

      # imagine there are three slots: subject, verb, object.
      #
      # • assume there is no subject.
      #
      # • take what used to be the object. this will be the subject.
      #
      # • take what used to be the verb. note its tense. turn it into a
      #   past participle (today a preterite). this will now be the object.
      #
      # • now the only thing missing is a verb. make a new copula, inflect
      #   it with the noted tense. done.

      class << self

        def _call a, b, c
          new( a, b, c ).execute
        end
        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      def initialize y, expag, stmsh
        @y = y
        @expag = expag
        @statementish = stmsh
      end

      def execute

        @_new_statement = @statementish.class.begin_

        __move_object_over_to_subject
        __make_past_participle_of_verb_and_put_it_as_the_object
        __make_inflected_copula_as_verb

        @_new_statement.express_into_under @y, @expag
      end

      def __move_object_over_to_subject

        onp = @statementish.verb_phrase.object_noun_phrase  # assume for now
        onp or self._HOLE  # entirely possible this isn't here, don't get this far
        @_new_statement.subject = onp
        NIL_
      end

      def __make_past_participle_of_verb_and_put_it_as_the_object

        otr = @statementish.verb_phrase.dup

        otr.nilify_object__

        @_tense = otr.tense  # note any tense before we clobber it

        otr << :preterite  # LOOK would be past participle if we had it

        @_will_be_object = otr
        NIL_
      end

      def __make_inflected_copula_as_verb

        _tense = remove_instance_variable( :@_tense ) || :present
        _preterite_verb_as_object = remove_instance_variable :@_will_be_object

        o = Siblings_::Predicateish.begin_

        o.lemma_symbol = :be

        o << _tense

        o.object_noun_phrase = _preterite_verb_as_object

        @_new_statement.verb_phrase = o
        NIL_
      end
    end
  end
end
