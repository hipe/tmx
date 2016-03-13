require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes  # #[#017]
  module Attributes

    TS_.describe "[fi] attributes - custom meta attributes - manually" do

      TS_[ self ]
      use :memoizer_methods
      Attributes[ self ]

      context "for example if you wanted a \"list\"-style (`argument_arity` many)" do

        it "ok." do
          o = _cls.new_with :foopie, :x, :foopie, :y, :harbinger, :j, :foopie, :z
          o.foopie.should eql [ :x, :y, :z ]
          o.harbinger.should eql :j
        end

        shared_subject :_cls do

          class X_CMAE_Attr < Subject_module_[]::Lib::DefinedAttribute
            # oh. nothing, i guess

            def __hello
              true
            end
          end

          class X_CMAE_Mattrs  # note we only define what we will use..

            def initialize bld
              @_build = bld
            end

            def list

              ca = @_build.current_attribute

              ca.write_by do |x|
                atr = formal_attribute
                atr.__hello or ::Kernel.fail
                ivar = atr.as_ivar
                sess = session
                if sess.instance_variable_defined? ivar
                  a = sess.instance_variable_get ivar
                else
                  a = []
                  sess.instance_variable_set ivar, a
                end
                a.push x
                true  # KEEP_PARSING_
              end
            end
          end

          class X_CMAE_A

            def self.new_with * x_a
              o = new
              _kp = self::ATTRIBUTES.init o, x_a
              _kp or self._SANITY
              o
            end

            attrs = Subject_module_[].call(
              foopie: :list,
              harbinger: nil,
            )

            attr_reader( * attrs.symbols )

            attrs.meta_attributes = X_CMAE_Mattrs
            attrs.attribute_class = X_CMAE_Attr

            const_set :ATTRIBUTES, attrs

            self
          end
        end
      end
    end
  end
end
