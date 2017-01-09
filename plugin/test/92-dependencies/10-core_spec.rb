require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] depdendencies" do

    TS_[ self ]
    use :dependencies

    context "(one)" do

      before :all do

        class De1_Dep
          ROLES = [ :wazoozoo ]
          SUBSCRIPTIONS = nil
        end
      end

      it "whine about strange role" do

        o = subject_class_.new
        o.roles = [ :weezy ]
        cls = De1_Dep

        begin
          o.index_dependency cls
        rescue Home_::ArgumentError => e
        end

        e.message.should eql(
          "role 'wazoozoo' not found - did you mean weezy?" )
      end
    end

    context "(two)" do

      before :all do

        module De2
          class Dep1
            ROLES = [ :wizzie ]
            SUBSCRIPTIONS = nil
          end

          class Dep2
            ROLES = [ :wizzie ]
            SUBSCRIPTIONS = nil
          end
        end
      end

      it "whine about colliding roles (and load all in module)" do

        o = subject_class_.new
        o.roles = [ :wizzie ]
        mod = De2
        begin
          o.index_dependencies_in_module mod
        rescue Home_::ArgumentError => e
        end

        e.message.should match (
          /\Arole 'wizzie' cannot be assumed by [:A-Za-z0-9]+::Dep2, #{
            }it is already assumed by [:A-Za-z0-9]+::Dep1\z/ )
      end
    end

    context "(three)" do

      before :all do

        class De3
          ROLES = nil
          SUBSCRIPTIONS = [ :szoi ]
        end
      end

      it "whine about strange subscription" do

        o = subject_class_.new
        o.emits = [ :sai, :sei, :soi, :ziff, :sui ]
        mod = De3
        begin
          o.index_dependency mod
        rescue Home_::ArgumentError => e
        end

        e.message.should eql(
          "emission channel 'szoi' not found - did you mean soi or sai or sei or sui?" )
      end
    end

    context "(four)" do

      before :all do

        module De2_Box

          class One

            ROLES = nil
            SUBSCRIPTIONS = [ :heartbeat ]

          end

          class Two

            ROLES = [ :heart ]
            SUBSCRIPTIONS = nil

          end

          class Three

            ROLES =  nil
            SUBSCRIPTIONS = nil

          end
        end
      end

      it "internally, \"dep\" w/ neither subscription nor role is ignored" do
        _o.instance_variable_get( :@_formals ).length.should eql 2
      end

      it "a role's implementer can be `nil`" do
        _o[ :lungs ].should be_nil
      end

      it "you cannot, however, aref a strange role" do

        begin
          _o[ :fungs ]
        rescue Home_::ArgumentError => e
        end
        e.message.should eql(
          "role 'fungs' not found - did you mean lungs or heart?" )
      end

      it "accessing a role works (instantiates object lazily)" do
        _o[ :heart ].class.should eql De2_Box::Two
      end

      it "is memoized" do
        _o[ :heart ].object_id.should eql _o[ :heart ].object_id
      end

      it "pubby that subby" do

        a = []
        _o.accept_by :heartbeat do | de |
          a.push de
          nil
        end
        1 == a.length or fail
        a.first.class.should eql De2_Box::One
      end

      dangerous_memoize :_o do

        o = subject_class_.new
        o.roles = [ :lungs, :heart ]
        o.emits = [ :fartbeat, :heartbeat ]

        o.index_dependencies_in_module De2_Box
        o

      end
    end
  end
end
