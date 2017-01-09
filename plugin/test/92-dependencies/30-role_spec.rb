require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] dependencies - roles" do

    TS_[ self ]
    use :dependencies

    # -> "one"

      before :all do

        module De_Ro1

          class C1
            ROLES = [ :jumper ]
            SUBSCRIPTIONS = nil
          end

          class C2
            ROLES = [ :shaker ]
            SUBSCRIPTIONS = nil
          end

          class C3
            ROLES = [ :other_guy ]
            SUBSCRIPTIONS = nil
          end
        end
      end

      it "change strategies" do

        o = _build_common_guy
        :C1 == _name( o[ :jumper ] ) or fail
        :C2 == _name( o[ :shaker ] ) or fail

        o.change_strategies :jumper, :shaker, o[ :other_guy ]

        :C3 == _name( o[ :jumper ] ) or fail
        :C3 == _name( o[ :shaker ] ) or fail
      end

      # <-

    def _build_common_guy
      o = subject_class_.new
      o.roles = [ :other_guy, :jumper, :shaker ]
      o.index_dependencies_in_module De_Ro1
      o
    end

    colon = ':'
    define_method :_name do | o |
      s = o.class.name
      s[ ( s.rindex( colon ) + 1 ) .. -1 ].intern
    end
  end
end
