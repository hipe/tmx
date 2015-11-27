require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] dependencies - duping" do

    TS_[ self ]
    use :dependencies

    context "(one)" do

      before :all do

        class De_Du1_Dep

          attr_reader(
            :block,
            :mama,
          )

          def initialize mama, & x_p
            @block = x_p
            @mama = mama
          end

          protected :initialize

          def dup mama, & x_p
            otr = super( & nil )
            otr.initialize mama, & x_p
            otr
          end
        end

        module De_Du1_Box

          class C1 < De_Du1_Dep

            ROLES = nil
            SUBSCRIPTIONS = nil
          end

          class C2 < De_Du1_Dep

            ROLES = nil
            SUBSCRIPTIONS = [ :zaza ]

            def honk
              "#{ @mama } #{ @block[] }"
            end
          end

          class C3 < De_Du1_Dep

            ROLES = [ :nana, :whohah ]
            SUBSCRIPTIONS = nil

            attr_accessor :some_attr
          end
        end
      end

      it "the dup has the same constituency profile in terms of role providers" do

        o, o_ = _pair

        o[ :nana ] or fail
        o[ :whohah ] or fail
        o[ :zed ] and fail

        o_[ :nana ] or fail
        o_[ :whohah ] or fail
        o_[ :zed ] and fail
      end

      it "the dup has ITS OWN DEEP COPY of a graph with THE SAME STRUCTURE" do

        o, o_ = _pair

        obj = o[ :nana ]
        obj or fail  # repeat for sanity
        oid = obj.object_id
        oid == o[ :whohah ].object_id or fail

        obj_ = o_[ :nana ]
        obj_ or fail  # ditto
        oid == obj_.object_id and fail
        obj_.object_id == o_[ :whohah ].object_id or fail
      end

      it "the dup shallow-copied over some ivars per platform default" do

        o, o_ = _pair

        s = o[ :whohah ].some_attr
        s_ = o_[ :whohah ].some_attr
        s.should eql "hi"
        s_.object_id.should eql s.object_id
      end

      it "the orig has the orig construction args, and the dup has the others" do

        o, o_ = _pair
        o[ :nana ].mama.should eql :mama_1
        o[ :nana ].block.call.should eql :k1

        o_[ :nana ].mama.should eql :mama_2
        o_[ :nana ].block.call.should eql :k2
      end

      it "subscriptions likewise copied over" do

        o, o_ = _pair

        a = []
        o.accept_by :zaza do | pu |
          a.push pu.honk
        end

        a_ = []
        o_.accept_by :zaza do | pu |
          a_.push pu.honk
        end

        a.should eql [ 'mama_1 k1' ]
        a_.should eql [ 'mama_2 k2' ]
      end

      dangerous_memoize :_pair do

        o = subject_class_.new :mama_1 do :k1 end

        o.roles = [ :whohah, :nana, :zed ]
        o.emits = [ :zizi, :zaza ]
        o.index_dependencies_in_module De_Du1_Box

        o[ :nana ].some_attr = "hi"

        _o_ = o.dup :mama_2 do :k2 end

        [ o, _o_ ]
      end
    end
  end
end
