module Skylab::TanMan::TestSupport

  module Models::Meaning

    class << self

      def [] tcc
        tcc.include self
      end
    end  # >>

    # -

      # -- assertion

      def want_result_from_add_is_entity__
        _t = tuple_
        _rslt = _t.result_of_API_call
        ent = _rslt.user_value
        ent.HELLO_MEANING
        ent.dereference( :name ) == "foo" || fail
        ent.dereference( :value ) == "bar" || fail
      end

      def want_content_from_add_is__ expected_s
        _actual = s
        _actual == expected_s || fail
      end

      def s  # 1x here, 1x in test (for legacy code, adapted)
        _t = tuple_
        _t.big_string
      end

      # -- setup

      def graph_from * s_pair_a

        fly = MockMeaning___.new

        _st = Home_::Common_::Stream.via_nonsparse_array s_pair_a do | s, s_ |
          fly.__reinit_ s_, s
        end

        Home_::Models_::Meaning::Graph__.new _st
      end

      def insert_foo_bar_into s  # (legacy name)

        call_API_for_add_meaning_ s

        want :success, :wrote_resource

        _x = execute
        ThisOneTuple___.new _x, s
      end

      def call_API_for_add_meaning_ s

        call_API(
          :meaning, :add,
          :input_string, s,
          :output_string, s,
          :name, "foo",
          :value, "bar",
        )
        NIL
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

    ThisOneTuple___ = ::Struct.new(
      :result_of_API_call,
      :big_string,
    )

    ItemSnapshot___  = ::Struct.new(
      :value_string,
      :natural_key_string,
      :object_id_of_item,
    )

    class MockMeaning___ < ::BasicObject

      def initialize
        NOTHING_  # hi.
      end

      def __reinit_ v_s, n_s
        @value_string = v_s ; @natural_key_string = n_s ; self
      end

      attr_reader(
        :natural_key_string,
        :value_string,
      )
    end

    # ==
    # ==
  end
end
