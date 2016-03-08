module Skylab::Fields

  module Events

    Autoloader_[ self ]
  end

  module Events_Support_  # #[#sl-155] scope stack trick

    DEFAULT_PROPERTY_LEMMA_ = 'property'.freeze

    # --

    Events::Missing = Callback_::Event.prototype_with(

      :missing_required_properties,

      :miss_a, nil,
      :selection_stack, nil,
      :lemma, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      s_a = o.miss_a.map do |x|
        par x
      end

      ss = o.selection_stack
      if ss

        _s_a = ss[ 1 .. -1 ].map do |frame|
          nm frame.name
        end

        _verb = "#{ _s_a.join SPACE_ } was "
      end

      _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA_

      y << "#{ _verb }missing required #{ plural_noun s_a.length, _lemma } #{
        }#{ and_ s_a }"
    end

    class << Events::Missing

      def for_attribute x
        via [ x ]
      end

      def for_attributes a
        via a
      end

      def new_via_arglist a
        via( * a )
      end

      def via miss_a, lemma=nil

        miss_a.first.respond_to?( :id2name ) and raise ::ArgumentError

        new_with(
          :miss_a, miss_a,
          :lemma, lemma,
        )
      end
    end
  end
end
