require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] depdendencies - argument - composite (partial)" do

    TS_[ self ]
    use :dependencies

    context "(one)" do

      before :all do

        module DeAC1_Box

          class In_Season_Vegetables

            ROLES = [ :veg ]
            SUBSCRIPTIONS = [ :argument_bid_for ]

            def initialize

              o = Home_::Dependencies.new self
              o.emits = [ :argument_bid_for ]
              o.index_dependencies_in_module Box
              @_deps = o
            end

            def argument_bid_for tok

              g = @_deps.argument_bid_group_for tok
              if g
                Home_::Dependencies::Argument::Bid.new(
                  self, g.arity_symbol, g )
              end
            end

            def receive_term term, bid

              Home_::Dependencies::Argument::Dispatch_term[
                bid.implementation_x, term ]
            end

            attr_accessor(
              :X_is_zoobie,
              :Y_is_zoobie,
            )

            module Box

              class X

                ARGUMENTS = [ :argument_arity, :zero, :property, :zoobie ]

                Home_::Dependencies::Argument::Has_arguments[ self ]

                def initialize x
                  @_parent = x
                end

                def receive__zoobie__flag
                  @_parent.X_is_zoobie = true
                  true
                end
              end

              class Y

                ARGUMENTS = [ :argument_arity, :zero, :property, :zoobie ]

                Home_::Dependencies::Argument::Has_arguments[ self ]

                def initialize x
                  @_parent = x
                end

                def receive__zoobie__flag
                  @_parent.Y_is_zoobie = true
                  true
                end
              end
            end
          end

          class Pear

            ARGUMENTS = [
              :argument_arity, :zero, :property, :pear,
            ]

            ROLES = [ :pear ]
            Home_::Dependencies::Argument::Has_arguments[ self ]

            def receive__pear__flag
              @do_use_pear = true
              true
            end

            attr_reader :do_use_pear
          end
        end
      end

      it "x." do

        o = subject_class_.new
        o.roles = [ :pear, :veg ]
        o.emits = [ :argument_bid_for ]
        o.index_dependencies_in_module DeAC1_Box

        st = argument_stream_via_ :pear, :zoobie
        o.process_polymorphic_stream_fully st or fail

        o[ :pear ].do_use_pear or fail
        o_ = o[ :veg ]

        o_.X_is_zoobie or fail
        o_.Y_is_zoobie or fail
      end
    end
  end
end
