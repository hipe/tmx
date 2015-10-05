module Skylab::Brazen

  module Property

    Events::Extra = Callback_::Event.prototype_with(

      :extra_properties,

      :name_x_a, nil,
      :did_you_mean_i_a, nil,
      :lemma, nil,
      :adj, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      s_a = o.name_x_a.map( & method( :ick ) )

      _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA_

      s = o.adj
      adj_ = if s
        "#{ s } "
      else
        "unrecognized "
      end

      # e.g: "unrecognized property 'foo'"

      y << "#{ adj_ }#{ plural_noun s_a.length, _lemma }#{
        } #{ and_ s_a }"

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
