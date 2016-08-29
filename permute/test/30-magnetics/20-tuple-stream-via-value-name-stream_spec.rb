require_relative '../test-support'

module Skylab::Permute::TestSupport

  describe "[pe] magnetics - tuple stream via pair stream" do

    TS_[ self ]

    # the tests have names like "NxM" where N is the number of total categories
    # and M is the maxium number of values provided for any one category.

    it "2x2" do

      _act = _against(
        [ :a, :letter ],
        [ :b, :letter ],
        [ :one, :number ],
        [ :two, :number ],
      )

      _act == [
        [ :a, :one ],
        [ :a, :two ],
        [ :b, :one ],
        [ :b, :two ],
      ] or fail
    end

    it "0" do
      _act = _against
      _act == Common_::EMPTY_A_ || fail
    end

    it "1x1" do
      _act = _against [ :one_val, :one_name ]
      _act == [[ :one_val ]] || fail
    end

    it "2x1" do
      _act = _against [ :v1, :cat ], [ :v2, :cat2 ]
      _act == [ [:v1, :v2] ] || fail
    end

    it "1x2" do
      _act = _against [ :v1, :cat1 ], [ :v2, :cat1 ]
      _act == [ [:v1], [:v2] ] || fail
    end

    it "3x2" do

      act = _against(
        [ :happy, :emotion ], [ :ecstatic, :emotion ],
        [ :red, :color ], [ :blue, :color ],
        [ :cat, :animal ], [ :dog, :animal ],
      )

      act.pop == [ :ecstatic, :blue, :dog ] || fail
      act.pop == [ :ecstatic, :blue, :cat ] || fail
      act.pop == [ :ecstatic, :red, :dog ] || fail
      act.pop == [ :ecstatic, :red, :cat ] || fail
      act.pop == [ :happy, :blue, :dog ] || fail
      act.pop == [ :happy, :blue, :cat ] || fail
      act.pop == [ :happy, :red, :dog ] || fail
      act.pop == [ :happy, :red, :cat ] || fail
      act.length.zero? || fail
    end

    def _against * pairs

      _st = Common_::Stream.via_nonsparse_array pairs

      _st_ = Home_::Magnetics::TupleStream_via_ValueNameStream[ _st ]

      _st_.map_by do |sct|
        sct.values
      end.to_a
    end
  end
end
