require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] ordered via dependency trees" do

    TS_[ self ]
    use :memoizer_methods

    context "example 1" do

      it "loads" do
        _subject_module
      end

      shared_subject :_performance do

        # we're making a peanut butter and jelly sandwich, with a garnish.
        # each of these "items" either has a prerequisite or it doesn't.
        # the garnsih and bread have no prerequisite; they can go whenever.
        # the peanut butter and jelly each (individually) require that the
        # bread has gone before them.

        _proto = X_s_ovdt_prototype[]

        _a = [
          X_x_ovdt_item[ :peanut_butter, :bread ],
          X_x_ovdt_item[ :garnish ],
          X_x_ovdt_item[ :bread ],
          X_x_ovdt_item[ :jelly, :bread ],
        ]

        _st_ = _proto.execute_against Home_::Stream.via_nonsparse_array _a

        _st_.to_a
      end

      it "runs" do
        _performance || fail
      end

      it "order is as expected" do
        _exp = %i( garnish bread peanut_butter jelly )
        _performance.map( & :_my_name ) == _exp || fail
      end
    end

    subject_module = -> do
      Home_::Stream::Ordered_via_DependencyTree
    end

    X_s_ovdt_prototype = Home_::Lazy.call do
      subject_module[].prototype_by do |o|
        o.method_name_for_identifying_key = :_my_name
        o.method_name_for_reference_key = :_i_go_after
      end
    end

    X_x_ovdt_item = ::Struct.new :_my_name, :_i_go_after

    define_method :_subject_module, subject_module
  end
end
