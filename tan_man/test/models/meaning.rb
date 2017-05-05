module Skylab::TanMan::TestSupport

  module Models::Meaning

    class << self

      def [] tcc
        tcc.include self
      end
    end  # >>

    # -

      # -- assertion

      # -- setup

      def graph_from * s_pair_

        _st = Home_::Common_::Stream.via_nonsparse_array s_pair_a do | s, s_ |
          Home_::Models_::Meaning.new s, s_
        end

        Home_::Models_::Meaning::Graph__.new _st
      end

      def matrix_of_item_snapshots_via_meaning_stream_ st
        a = []
        begin
          ent = st.gets
          ent || break
          _nat_key_s = ent.natural_key_string
          _value_s = ent.value_string
          a.push ItemSnapshot___.new _value_s, _nat_key_s, ent.object_id
          redo
        end while above
        a
      end
    # -

    # ==

    ItemSnapshot___  = ::Struct.new(
      :value_string,
      :natural_key_string,
      :object_id_of_item,
    )

    # ==
    # ==
  end
end
