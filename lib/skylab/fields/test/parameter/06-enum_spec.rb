require_relative '../test-support'

describe '[fi] P - enum: given "object" with parameter "foo"' do

  extend Skylab::Fields::TestSupport
  use :parameter

  context 'and "foo" has the property of e.g. "enum: [:alpha, :beta]"' do

    context 'you get no readers or writers out of the box so..' do

      with do
        param :color, :enum, [ :red, :blue ]
      end

      frame do

        it "at declaration time, it will complain that there is no writer" do
          begin
            the_class_
          rescue ::ArgumentError => e
          end
          e.message.should eql "`enum` modifier #{
            }must come after a modification that establishes a writer method"
        end
      end
    end

    context 'but if "foo" is a regular writer' do

      with do
        param :color, :writer, :enum, [ :red, :blue ]
      end

      spy_on_events_

      frame do

        it '"object.foo = :beta" (a valid value) changes the parameter value' do

          object = object_

          expect_unknown_ :color, object

          object.color = :blue

          force_read_( :color, object ).should eql :blue
        end

        it "`object.foo = :gamma` will emit an error event" do

          object = object_
          object.color = :orange
          expect_not_OK_event :invalid_property_value,
            "invalid color (ick :orange), expecting { red | blue }"

          expect_unknown_ :orange, object
        end
      end
    end
  end
end
