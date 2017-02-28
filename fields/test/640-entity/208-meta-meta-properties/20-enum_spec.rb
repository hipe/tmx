require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - meta-meta-properties - enum" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    it "(minimal)" do

        class X_e_mmp_enum_Min
          Entity.lib.call self do
            o :enum, [ :foo, :bar ], :meta_property, :zig
          end
        end
    end

    context "a normative example is boring" do

      shared_subject :_subject_module do

        class X_e_mmp_enum_Foo

          Entity.lib.call self do

            o :enum, [ :red, :blue ],

              :meta_property, :color,

              :argument_scanning_writer_method_name_suffix, :"=",

              :color, :red

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

          end
          self
        end
      end

      it "the properties abstraction is useful here with `group_by`" do
        h = _subject_module.properties.group_by( & :color )
        a = h.keys
        a.length.should eql 3
        ( a - [ :red, :blue, nil ] ).length.should be_zero
        h[ :red ].map( & :name_symbol ).should eql [ :red_thing ]
        h[ :blue ].map( & :name_symbol ).should eql [ :blue_thing, :other_blue_thing ]
        h[ nil ].map( & :name_symbol ).should eql [ :no_color ]
      end
    end

    it "enums try and prevent you from being naughty" do

      _rx = /\Ainvalid color 'red', expecting { green \| purple }/

      begin
        class X_e_mmp_enum_Bar

          Entity.lib.call self do

            o :enum, [ :green, :purple ],
              :meta_property, :color

            o :color, :red

            def wizzo
            end
          end
        end
      rescue Home_::ArgumentError => e
      end

      e.message.should match _rx
    end
  end
end
