require_relative 'test-support'

module Skylab::Callback::TestSupport::Actor::Methodic::MP

  Parent_TS_ = Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Grandparent_Subject_ = Parent_TS_::Parent_subject_

  describe "[cb] actor - methodic - enhancer modules" do

    context "a 'simple properties' enhancer module can access its properties class" do

      it "like so" do
        x = module A
          Grandparent_Subject_[].methodic self, :simple, :properties

          property_class_for_write
        end

        x.should eql A::Property
      end
    end

    context "a 'simple properties' enhancer module can enhance a class" do

      it "which has the effect of putting a (possibly custom) p.class in chain" do

        module B
          Grandparent_Subject_[].methodic self, :simple, :properties
          property_class_for_write
        end

        class B_2
          B[ self, :simple, :properties, :properties, :x, :z ]
        end

        B_2::Property.should eql B::Property

      end
    end

    context "SO, if in an enhancer module you add custom syntax to the p.cls" do

      before :all do

        module C
          Grandparent_Subject_[].methodic self, :simple, :properties
          property_class_for_write

          class Property

            def initialize( * )
              @parameter_arity = :one  # here make required the default
              super
            end

          private

            def flag=
              @argument_arity = :zero
            end

            def optional=
              @parameter_arity = :zero_or_one
            end
          end
        end
      end

      define_method :require_C_1, ( Callback_.memoize do

        class C_1

          C.call self, :simple, :properties,
            :optional, :first_name,
            :last_name,
            :flag, :ivar, :'@imp', :important

          alias_method :initialize, :instance_exec
        end

      end )

      it "when defining your cls you can use the custom syntax defined in the p.cls" do
        require_C_1
        C_1.properties.get_names.should eql [ :first_name, :last_name, :important ]
      end

      it "when doing iambics on your business instance, they use syntax of p.cls" do
        require_C_1
        o = C_1.new do
          process_iambic_fully [ :last_name, :Jernkerns, :important ]
        end
        o.instance_variable_get( :"@imp" ).should eql true
        o.instance_variable_get( :@last_name ).should eql :Jernkerns
      end
    end

    context "your enhancer can model module methods in its module methods module" do

      before :all do

        module D
          Grandparent_Subject_[].methodic self, :simple, :properties
          property_class_for_write
          class Property
          private
            def required=
              @parameter_arity = :one
            end
          end
          module_methods_module_for_write
          module ModuleMethods
            def required_properties_scan
              properties.to_scan.reduce_by do |prop|
                prop.is_required
              end
            end
          end
        end

        class D_2
          D.call self, :simple, :properties,
            :required, :foo,
            :bar,
            :required, :baz

          alias_method :initialize, :instance_exec
        end

      end

      it "loads" do
      end

      it "works" do
        o = D_2.new do
          process_iambic_fully [ :bar, :hi ]
          nilify_uninitialized_ivars
        end
        _scan = o.class.required_properties_scan
        a = _scan.reduce_by do |prop|
          o.instance_variable_get( prop.as_ivar ).nil?
        end.to_a
        a.map( & :name_i ).should eql [ :foo, :baz ]
      end
    end
  end
end
