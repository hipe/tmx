require_relative 'test-support'

module Skylab::MetaHell::TestSupport::DSL_DSL::Constant_Trouble

  ::Skylab::MetaHell::TestSupport::DSL_DSL[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  MetaHell = MetaHell

  describe "#{ MetaHell }::DSL_DSL::Constant_Trouble" do

    # OK, deep breath, here goes: constant trouble is a facility for producing
    # classes. Specifically it is a class that produces a subclass of itself
    # (like ::Struct), and with that subclass you call `enhance` on it,
    # and that call 1) produces a class 2) that is a subclass of a particular
    # class and 3) puts that class in a certain module 4) using a certain
    # const name. Furthermore, the defition block will be used to set the
    # "fields" of that class..
    #

    context "ctx" do

      it "ok." do
        module M1

          class Blammo  # blammo is my all powerful class that i will
                        # enhance you with.
          end

          DSL = MetaHell::DSL_DSL::Constant_Trouble.
            new :Blammo_, Blammo, [ :hip_hop, :horay ]

                        # you will get one called this that descends from
                        # this (Blammo) that has these fields.

          class Blammo  # but i still want to define how i will let you
            def self.enhance yours, &block  # enhance yourself with me
              DSL.enhance yours, block
            end
          end

          module Yours  # ok now here's yours.

            Blammo.enhance self do  # oh, i see you would like to enhance

              hip_hop do            # well look who's using the DSL
                :family_fun         # here you have defined a resolution
              end                   # for the field using a block

              horay "HARAY."        # and here you have a straigt up literal.
            end
          end
        end

        # step outside that sandbox module with me for a moment here, look
        # what i gave you:

        M1::Yours::Blammo_::HIP_HOP_.call.should eql( :family_fun ) # woah
                                    # note it is still a proc

        M1::Yours::Blammo_::HORAY_.should eql( 'HARAY.' )  # note this is not

        yep = M1::Yours::Blammo_.new
        yep.hip_hop.should eql( :family_fun )  # calls proc
        yep.horay.should eql( 'HARAY.' )       # result is value
        yep.hip_hop = 'otr'                    # discards proc for literal
        yep.hip_hop.should eql( 'otr' )
        yep.horay = 'foo'
        yep.horay.should eql( 'foo' )
      end
    end
  end
end
