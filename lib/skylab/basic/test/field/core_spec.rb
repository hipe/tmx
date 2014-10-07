require_relative 'test-support'

module Skylab::Basic::TestSupport::Field

  describe "[ba] field" do  # read [#003] storypoint-1313

    extend TS_

    context "foundations" do
      it "(the basics of making sure the classes loaded)" do
        Basic_::Field::Box
      end
    end

    context "introduction" do

      define_sandbox_constant :Mod_0 do

        module Sandbox::Mod_0

          Basic_::Field::Box.enhance self do

            meta_fields [ :required, :reflective ]

            fields [ :email ]

          end
        end
      end

      it "minimal - smoketest regression" do
        self.Mod_0
      end

      define_sandbox_constant :Mod_1 do

        module Sandbox::Mod_1

          Basic_::Field::Box.enhance self do

            meta_fields :important, :fun

            fields [ :hacking, :important ], [ :working, :fun ],
                   [ :family, :important, :fun ]

          end
        end
      end

      it 'is concerned mainly with making boxes' do

        mod1 = self.Mod_1
        box = mod1.field_box
        box.names.should eql( %i( hacking working family ) )

      end

      it "with `field_box` you can reflect on its metafields" do
        box = self.Mod_1.field_box
        hacking = box.fetch :hacking
        working = box.fetch :working
        hacking.is_important.should eql( true )
        working.is_important.should eql( nil )  # ..
      end
    end

    context "model integrity" do

      define_sandbox_constant :Mod_2 do
        module Sandbox::Mod_2
          Basic_::Field::Box.enhance self do
            fields [ :name, :required ]
            meta_fields :gadzooks
          end
        end
      end

      it "model integrity is asserted - you must declare all metafields" do

        -> do
          self.Mod_2
        end.should raise_error( ::KeyError,
                     /no such meta-field "required" - expecting "gadzooks/i )
      end

      define_sandbox_constant :Mod_2_2 do
        module Sandbox::Mod_2_2
          Basic_::Field::Box.enhance self do
            meta_fields [ :wanktastic, :merbles ]
          end
        end
      end

      it "model integrity errors can happen in the n-th dimension" do
        -> do
          self.Mod_2_2
        end.should raise_error( ::KeyError,
                             /no such meta-meta-field "merbles"/i )

      end
    end

    context "fields with properties - the next dimension" do

      define_sandbox_constant :Mod_3 do
        module Sandbox::Mod_3
          Basic_::Field::Box.enhance self do

            meta_fields [ :range, :property ], :urgent

            fields :sex, [ :location, :urgent ], [ :age, :range, [1..2] ]

          end
        end
      end

      it "where you would expect a hash, we sill use s-expressions" do

        self.Mod_3
        a, s, l = self.Mod_3.field_box.at :age, :sex, :location
        a.local_normal_name.should eql( :age )
        s.local_normal_name.should eql( :sex )
        l.local_normal_name.should eql( :location )
        a.is_urgent.should eql( nil )
        s.is_urgent.should eql( nil )
        l.is_urgent.should eql( true )
        a.has_range.should eql( true )
        s.has_range.should eql( nil )
        l.has_range.should eql( nil )
        a.range_value.should eql( [1..2] )
        -> do
          s.range_value
        end.should raise_error( /"range" is undefined for "sex" so #{
          }this call to `range_value` is meaningless - use `has_range` #{
          }to check this before calling `range_value`\./ )
      end
    end
  end
end
