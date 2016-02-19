module Skylab::Brazen

  module Property

    Events::Extra = Callback_::Event.prototype_with(

      :extra_properties,

      :name_x_a, nil,
      :did_you_mean_i_a, nil,
      :prefixed_conjunctive_phrase_context_proc, nil,
      :prefixed_conjunctive_phrase_context_stack, nil,
      :suffixed_prepositional_phrase_context_proc, nil,
      :lemma, nil,
      :adj, nil,
      :invite_to_action, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      # e.g: "couldn't wizzle - unrecognized property 'foo' in blah blah"

      a = []
      p = o.prefixed_conjunctive_phrase_context_proc
      if p
        calculate a, o, & p
      end

      s = o.adj
      a.push s || "unrecognized"

      s_a = o.name_x_a.map( & method( :ick ) )
      _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA_
      a.push plural_noun s_a.length, _lemma

      a.push and_ s_a

      p = o.suffixed_prepositional_phrase_context_proc
      if p
        calculate a, o, & p
      end

      y << a.join( SPACE_ )

      if o.did_you_mean_i_a
        _s_a_ = o.did_you_mean_i_a.map( & method( :code ) )
        y << "did you mean #{ or_ _s_a_ }?"
      end
    end

    class << Events::Extra

      def new_via_arglist a
        __new_via( * a )
      end

      def __new_via name_x_a, did_you_mean_i_a=nil, lemma=nil, adj=nil

        new_with(
          :name_x_a, name_x_a,
          :did_you_mean_i_a, did_you_mean_i_a,
          :lemma, lemma,
          :adj, adj )
      end
    end
  end
end
