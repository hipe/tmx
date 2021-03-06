module Skylab::Fields

  module Toolkit  # :[#029.A]

    # (this node (file) was created/repurposed to act as a transitional
    # bridge, insulating outside clients from whatever mess is going on in
    # (for example) our normalization node. but since we have cleaned that
    # one up..

    # ==

      Receive_entity_nouveau = -> o, ent do  # 1x this lib only. o=normalization

        # implement `entity_nouveau=` in a different file than n11n to lighten it
        # (it happens here for purely historical reasons)

        # NOTE unlike many of the others, this one is call-time sensitive!
        # (what is and isn't already set in the o will inform what happens here.)

        if o.association_source
          NOTHING_  # [sn], [ta]
        else
          self._WHERE  # #see #tombstone-B
        end

        o.argument_scanner_narrator = ent._argument_scanner_narrator_  # ..

        if o.listener
          self._COVER_ME
        else
          o.listener = ent._listener_
        end

        o.arguments_to_default_proc_by = -> _ do
          [ ent, o.listener ]  # (last element is the block to pass)
        end

        ent.respond_to? :_simplified_read_ or no  # #open [#015] (next line too)
        ent.respond_to? :_simplified_write_ or no

        o.valid_value_store = ent
      end

    # ==

    # (at #tombstone-B) "association stream via entity" moved to one of our test files)

    # ==

    define_singleton_method :properties_grammar_, ( Lazy_.call do

      _inj = Home_::CommonAssociation::EntityKillerParameter.grammatical_injection

      Home_.lib_.parse::IambicGrammar.define do |o|

        o.add_grammatical_injection :_parameter_FI_, _inj
      end
    end )

    # ==

    Here__ = self

    # ==
    # ==
  end
end
# #tombstone-B - moved "default" association streamer out (for now)
# #history-A - repurposed file from "stack" to "toolkit"
