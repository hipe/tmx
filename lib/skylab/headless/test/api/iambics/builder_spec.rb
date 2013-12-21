require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics builder" do

    it "money" do

      module Iambics_IB

        Headless::API::Iambic_builder[ self ]

        parameter__parse_class
        class Parameter::Parse
        private
          def parameter_arity=
            @param.param_arity_i = @x_a.shift ; nil
          end
        end

        parameter_class
        class Parameter
          attr_accessor :param_arity_i
        end

        instance_methods_module
        module Instance_Methods
          PROTOTYPE_PARAMETER = Parameter.new do |param|
            param.argument_arity_i = :one
            param.has_generated_writer = true
            param.param_arity_i = :one
          end

        private
          def initialize * x_a
            nilify_and_absorb_iambic_fully_with_parameter_arity_assertion x_a
            super()
          end
          def nilify_and_absorb_iambic_fully_with_parameter_arity_assertion x_a
            nilify_and_absorb_iambic_fully x_a
            assert_parameter_arity
          end
          def assert_parameter_arity
            scn = self.class.get_parameter_scanner
            y = nil
            while (( param = scn.gets ))
              :one == param.param_arity_i or next
              x = instance_variable_get param.ivar
              x.nil? or next
              ( y ||= [] ) << param
            end
            if y
              @error_message = "you are missing #{
                }#{ y.map( & :param_i ) * ' and ' }"
            end ; nil
          end
        public
          attr_reader :error_message
        end
      end

      class One_IB
        Iambics_IB[ self, :params, :a, :b,
                    :c, %i( parameter_arity zero_or_one ),
                    :d ]
      end

      one = One_IB.new :a, :hi
      one.error_message.should eql "you are missing b and d"
    end
  end
end
