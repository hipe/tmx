require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - simple meta parameteters" do

    before :all do

      class Foo_MP

        DSL[][ self, :DSL_writer_method_name, :paramos,
                     :reflection_method_stem, :parameto ]

        parameter_class_for_edit
        class Parameter
          attr_reader :arity
          def parameter_arity_i= i
            @arity = ARITIES__.fetch( i ) ; i
          end
        end

        class Parameter::Parse
        private
          def parameter_arity=
            @param.parameter_arity_i = @x_a.shift ; nil
          end
        end

        ARITIES__ = (( module Arities
          ONE = Headless_::Arity.new 1, 1
          ZERO_OR_ONE = Headless_::Arity.new 0, 1
          { one: ONE, zero_or_one: ZERO_OR_ONE }.freeze
        end ))

        PROTOTYPE_PARAMETER = Parameter.new do |param|
          param.argument_arity_i = :one
          param.has_generated_writer = true
          param.parameter_arity_i = :one
        end

        paramos :zerf, :tinkle, [ :parameter_arity, :zero_or_one ]

      end
    end

    it "loads" do
    end

    it "reflects" do
      scn = Foo_MP.get_parameto_scanner
      y = []
      p = -> param do
        y.push param.arity.local_normal_name, param.param_i
      end
      param = scn.gets and p[ param ]
      while(( param = scn.gets ))
        y << :and
        p[ param ]
      end
      y.should eql %i( one zerf and zero_or_one tinkle )
    end

    it "inherits, enumerates" do
      class Bar_MP < Foo_MP
        paramos :tankel, %i( parameter_arity zero_or_one )
      end

      optional = Bar_MP.parametos.select do |param|
        param.arity.includes_zero
      end
      required = Bar_MP.parametos.select do |param|
        ! param.arity.includes_zero
      end
      optional.map( & :param_i ).should eql %i( tinkle tankel )
      required.map( & :param_i ).should eql %i( zerf )
    end
  end
end
