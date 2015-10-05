module Skylab::Brazen

  module Property

    Events::Missing = Callback_::Event.prototype_with(

      :missing_required_properties,

      :miss_a, nil,
      :lemma, nil,
      :nv, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      s_a = o.miss_a.map do | prp |
        par prp
      end

      if o.nv
        _nv = "#{ o.nv }#{ SPACE_ }"
      end

      _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA_

      y << "#{ _nv }missing required #{ plural_noun s_a.length, _lemma } #{
        }#{ and_ s_a }"
    end

    class << Events::Missing

      def new_via_arglist a
        __new_via( * a )
      end

      def __new_via miss_a, lemma=nil, nv=nil

        miss_a.first.respond_to?( :id2name ) and raise ::ArgumentError

        new_with(
          :miss_a, miss_a,
          :lemma, lemma,
          :nv, nv )
      end
    end
  end
end
