require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: enum" do

    context "a normative example is boring" do

      before :all do

        class MME_Foo

          Subject_[][ self, :iambic_writer_method_name_suffix, :"=", -> do

            o :meta_property, :color, :enum, [ :red, :blue ]

            o :color, :red

            def red_thing=
            end

            o :color, :blue

            def blue_thing=
            end

            def no_color=
            end

            o :color, :blue

            def other_blue_thing=
            end

          end ]
        end
      end

      it "the properties abstraction is useful here with `group_by`" do
        h = MME_Foo.properties.group_by( & :color )
        a = h.keys
        a.length.should eql 3
        ( a - [ :red, :blue, nil ] ).length.should be_zero
        h[ :red ].map( & :name_i ).should eql [ :red_thing ]
        h[ :blue ].map( & :name_i ).should eql [ :blue_thing, :other_blue_thing ]
        h[ nil ].map( & :name_i ).should eql [ :no_color ]
      end

      it "enums try and prevent you from being naughty" do

        -> do
        class MME_Bar
          Subject_[][ self, -> do
            o :meta_property, :color, :enum, [ :green, :purple ]
            o :color, :red
            def wizzo
            end
          end ]
        end
        end.should raise_error ::ArgumentError,
          /\Ainvalid color 'red', expecting { green \| purple }/
      end
    end
  end
end
