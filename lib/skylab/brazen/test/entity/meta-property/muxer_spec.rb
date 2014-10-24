require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity::Muxer__

  ::Skylab::Brazen::TestSupport::Entity[ self ]

  include Constants

  extend TestSupport_::Quickie

  Subject_ = -> do
    Entity_[]::Meta_Property__::Muxer
  end

  describe "[br] entity muxer" do

    it "'notificate' with one class" do
      class One_Doodley_Hah
        Subject_[][ singleton_class, :MXR, :muxer_for_write ]
      end

      x = nil
      One_Doodley_Hah.muxer_for_write.add :zoopie, -> x_ { x = x_ }
      obj = One_Doodley_Hah.new
      obj.notificate :zoopie
      x.class.should eql One_Doodley_Hah
    end

    it "child has those of parent when add delegate to parent early" do

      class Two_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_write ]
      end

      class Two_Child < Two_Parent
      end

      x = nil
      Two_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      pa = Two_Parent.new ; ch = Two_Child.new

      ch.notificate :zing
      x.class.should eql Two_Child

      pa.notificate :zing
      x.class.should eql Two_Parent
    end

    it "child gets parent delegates **at the time** (no child delegates)" do

      class AtTime_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_write ]
      end

      class AtTime_Child < AtTime_Parent
      end

      x = nil
      AtTime_Parent.mx_for_write.add :zing, -> x_ { x = x_ }

      pa = AtTime_Parent.new ; ch = AtTime_Child.new

      pa.notificate :zing
      x.class.should eql AtTime_Parent

      ch.notificate :zing
      x.class.should eql AtTime_Child
    end

    it "child gets parent delegates **at the time** (when write child)" do

      class WrtChld_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_write ]
      end

      class WrtChld_Child < WrtChld_Parent
      end

      x = nil
      WrtChld_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      WrtChld_Child.mx_for_write.add :zong, -> x_ { x = x_ }

      ch = WrtChld_Child.new
      ch.notificate :zing
      x.class.should eql WrtChld_Child
    end

    it "child won't contaminate parent" do

      class NoCon_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_write ]
      end

      class NoCon_Child  < NoCon_Parent
      end

      x = nil
      NoCon_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      NoCon_Child.mx_for_write.add :zong, -> x_ { x = x_ }

      pa = NoCon_Parent.new ; ch = NoCon_Child.new

      pa.notificate :zing
      x.class.should eql NoCon_Parent

      x = :untouched
      pa.notificate :zong
      x.should eql :untouched

      ch.notificate :zing
      x.class.should eql NoCon_Child

      x = nil
      ch.notificate :zong
      x.class.should eql NoCon_Child

    end

    it "child WILL GET parent delegates that are added \"late\"" do

      class Late_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_write ]
      end

      class Late_Child < Late_Parent
      end

      x = nil
      Late_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      Late_Child.mx_for_write.add :zang, -> x_ { x = x_ }
      Late_Parent.mx_for_write.add :zong, -> x_ { x = x_ }

      pa = Late_Parent.new ; ch = Late_Child.new

      ch.notificate :zing
      x.class.should eql Late_Child

      x = nil
      ch.notificate :zang
      x.class.should eql Late_Child

      x = :untouched
      ch.notificate :zong
      x.class.should eql Late_Child

      pa.notificate :zong
      x.class.should eql Late_Parent
    end

    it "CRAZY GRAPHS WORK OMG" do

      p = Subject_[]
      Subject__ = -> x do
        p[ x, :MUXO, :notificate_muxer_for_write ]
      end

      module Mod_One
        Subject__[ singleton_class ]
      end

      module Mod_Two
        Subject__[ singleton_class ]
      end

      module Mod_Three
        Subject__[ singleton_class ]
        include Mod_One
      end

      class Cls_One
        Subject__[ singleton_class ]
        include Mod_Three
      end

      class Cls_Two < Cls_One
        include Mod_Two
      end

      mx = [] ; m2 = [] ; m3 = [] ; c1 = [] ; c2 = []

      Mod_One.notificate_muxer_for_write.add :mx, -> x { mx.push 0 }
      Mod_One.notificate_muxer_for_write.add :mx, -> x { mx.push 1 }
      Mod_Two.notificate_muxer_for_write.add :m2, -> x { m2.push 2 }
      Mod_Three.notificate_muxer_for_write.add :m3, -> x { m3.push 3 }
      Cls_One.notificate_muxer_for_write.add :c1, -> x { c1.push 4 }
      Cls_One.notificate_muxer_for_write.add :mx, -> x { mx.push 5 }
      Cls_Two.notificate_muxer_for_write.add :c2, -> x { c2.push 6 }

      ohai = Cls_Two.new
      ohai.notificate :mx
      ohai.notificate :m2
      ohai.notificate :m3
      ohai.notificate :c1
      ohai.notificate :c2

      m2.should eql [2]
      m3.should eql [3]
      c1.should eql [4]
      c2.should eql [6]
      mx.should eql [5, 1, 0]

    end
  end
end
