require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes  # #[#017]
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - desc" do

      TS_[ self ]
      use :memoizer_methods
      Attributes::Meta_Attributes[ self ]

      context "(context)" do

        shared_subject :entity_class_ do

          class X_Desc_A

            attrs = Subject_module_[].call(
              wazlow: [ :desc, -> y { y << "line 1: #{ self._hi }" ; y << "line 2" } ],
              pazlow: [ :desc, -> { "this way #{ self._hi }" } ],
            )

            ATTRIBUTES = attrs

            self
          end
        end

        it "multi line form" do

          _desc_lines_for( :wazlow ).should eql [ "line 1: _hello_", "line 2" ]
        end

        it "single line form" do

          _desc_lines_for( :pazlow ).should eql [ "this way _hello_" ]
        end
      end

      def _desc_lines_for k

        desc_p = attribute_( k ).description_proc

        if desc_p.arity.zero?
          [ _would_be_expression_agent.calculate( & desc_p ) ]
        else
          _would_be_expression_agent.calculate [], & desc_p
        end
      end

      memoize :_would_be_expression_agent do

        cls = class X_Desc_Expag

          alias_method :calculate, :instance_exec

          def _hi
            :_hello_
          end

          self
        end

        cls.new
      end
    end
  end
end
