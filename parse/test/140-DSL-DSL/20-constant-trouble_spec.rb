# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Parse::TestSupport

  module DD_CT___  # :+#throwaway-namespace for constants created in tests
    # <-

  TS_.describe "[pa] DSL DSL - constant trouble" do

    # OK, deep breath, here goes: constant trouble is a facility for producing
    # classes. Specifically it is a class that produces a subclass of itself
    # (like ::Struct), and with that subclass you call `enhance` on it,
    # and that call 1) produces a class 2) that is a subclass of a particular
    # class and 3) puts that class in a certain module 4) using a certain
    # const name. Furthermore, the defition block will be used to set the
    # "fields" of that class..
    #

    context "m1. a normal scenario." do
      m1 = -> do
        module M1

          class Blammo  # blammo is my all powerful class that i will
                        # enhance you with.
          end

          DSL = Home_::DSL_DSL::Constant_Trouble.
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
        m1 = -> { }
        nil
      end

      before :each do m1[] end      # hack before( :all ) support for quickie.

      it "first thing's first, with an object, access the values" do
        o = M1::Yours::Blammo_.new
        expect( o.hip_hop ).to eql :family_fun
        expect( o.horay ).to eql 'HARAY.'  # note it normalizes them - whether
        # you set it with a proc or a literal, you get the endvalue here.
      end

      it "also, access the underlying constants. note suffixes." do
        expect( ::Proc === M1::Yours::Blammo_::HIP_HOP_PROC_ ).to eql true
        expect( M1::Yours::Blammo_.const_defined? :HIP_HIP_VALUE_, false ).to eql false
        expect( M1::Yours::Blammo_::HORAY_VALUE_ ).to eql 'HARAY.'
        expect( M1::Yours::Blammo_.const_defined? :HORAY_PROC_, false ).to eql false
      end

      it "you can change the values (either) in the instance with `foo=`" do
        foo = M1::Yours::Blammo_.new
        foo.hip_hop = :klezmer
        expect( foo.hip_hop ).to eql :klezmer
        foo.hip_hop = :polka
        expect( foo.hip_hop ).to eql :polka
        foo.horay = :x
        expect( foo.horay ).to eql :x
        foo.horay = :y
        expect( foo.horay ).to eql :y
      end

      it "you can change the value in the instance with `set_foo_proc`" do
        foo = M1::Yours::Blammo_.new
        expect( foo.horay ).to eql 'HARAY.'
        foo.set_horay_proc -> { :zing }
        expect( foo.horay ).to eql :zing
      end
    end

    context "m2. you can set your field value resolvers late, as consts" do
      m = -> do
        module M2
          class Bongo
            Enhancer_ = Home_::DSL_DSL::Constant_Trouble.
              new :Bongo_, self, [ :wiptastik, :plastik ]
          end
          class Yours
            Bongo::Enhancer_.enhance self

            class Bongo_
              WIPTASTIK_VALUE_ = -> { :hi }
              PLASTIK_PROC_ = -> { :hey }
            end
          end
        end
        m = -> { }
        nil
      end

      before :each do m[] end

      it "like so." do
        y = M2::Yours::Bongo_.new
        expect( y.wiptastik.call ).to eql :hi
        expect( y.plastik ).to eql :hey
      end

      it "and still you can set them (but you can't go back.)" do
        y = M2::Yours::Bongo_.new
        expect( y.plastik ).to eql :hey
        y.plastik = :sure
        expect( y.plastik ).to eql :sure
      end
    end
  end
# ->
  end
end
