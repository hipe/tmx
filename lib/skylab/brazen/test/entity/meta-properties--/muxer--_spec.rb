require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity::Muxer__

  ::Skylab::Brazen::TestSupport::Entity[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Subject_ = -> do
    Brazen_::Entity::Meta_Properties__::Muxer
  end

  describe "[br] entity muxer" do

    it "has no mxr for read, creates on for write then has one for read" do

      class One_With_None_Then_One
        Subject_[][ singleton_class, :MXR, :mxr_for_read, :mxr_for_write ]
      end

      cls = One_With_None_Then_One
      cls.mxr_for_read.should be_nil
      ohai = cls.mxr_for_write
      ohey = cls.mxr_for_read
      ( ! ohai ).should eql false
      ohai.object_id.should eql ohey.object_id
    end

    it "child has those of parent when add listener to parent early" do

      class Two_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_read, :mx_for_write ]
      end

      class Two_Child < Two_Parent
      end

      Two_Parent.mx_for_read.should be_nil
      Two_Child.mx_for_read.should be_nil
      x = nil
      Two_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      Two_Child.mx_for_read.mux :zing, :hey
      x.should eql :hey
      Two_Parent.mx_for_read.mux :zing, :hi
      x.should eql :hi
    end

    it "child gets parent listeners **at the time** (no child listeners)" do

      class AtTime_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_read, :mx_for_write ]
      end

      class AtTime_Child < AtTime_Parent
      end

      x = nil
      AtTime_Parent.mx_for_write.add :zing, -> x_ { x = x_ }

      AtTime_Parent.mx_for_read.mux :zing, :A
      x.should eql :A

      AtTime_Child.mx_for_read.mux :zing, :B
      x.should eql :B
    end

    it "child gets parent listeners **at the time** (when write child)" do

      class WrtChld_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_read, :mx_for_write ]
      end

      class WrtChld_Child < WrtChld_Parent
      end

      x = nil
      WrtChld_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      WrtChld_Child.mx_for_write.add :zong, -> x_ { x = x_ }

      WrtChld_Child.mx_for_read.mux :zing, :A
      x.should eql :A

    end

    it "child won't contaminate parent" do

      class NoCon_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_read, :mx_for_write ]
      end

      class NoCon_Child  < NoCon_Parent
      end

      x = nil
      NoCon_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      NoCon_Child.mx_for_write.add :zong, -> x_ { x = x_ }

      NoCon_Parent.mx_for_read.mux :zing, :A
      x.should eql :A
      NoCon_Parent.mx_for_read.mux :zong, :B
      x.should eql :A
      NoCon_Child.mx_for_read.mux :zing, :C
      x.should eql :C
      NoCon_Child.mx_for_read.mux :zong, :D
      x.should eql :D

    end

    it "child will miss parent listeners that are added \"late\"" do

      class Late_Parent
        Subject_[][ singleton_class, :MXR, :mx_for_read, :mx_for_write ]
      end

      class Late_Child  < Late_Parent
      end

      x = nil
      Late_Parent.mx_for_write.add :zing, -> x_ { x = x_ }
      Late_Child.mx_for_write.add :zang, -> x_ { x = x_ }
      Late_Parent.mx_for_write.add :zong, -> x_ { x = x_ }

      Late_Child.mx_for_read.mux :zing, :A
      x.should eql :A
      Late_Child.mx_for_read.mux :zang, :B
      x.should eql :B
      Late_Child.mx_for_read.mux :zong, :C
      x.should eql :B
      Late_Parent.mx_for_read.mux :zong, :D
      x.should eql :D
    end
  end
end
