require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - custom meta attributes - manually" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

      context "for example if you wanted a \"list\"-style (`argument_arity` many)" do

        it "ok." do
          o = _cls.with :foopie, :x, :foopie, :y, :harbinger, :j, :foopie, :z
          o.foopie.should eql [ :x, :y, :z ]
          o.harbinger.should eql :j
        end

        shared_subject :_cls do

          class X_a_cma_m_Attr < Attributes.lib::DefinedAttribute
            # oh. nothing, i guess

            def __hello
              true
            end
          end

          class X_a_cma_m_Mattrs  # note we only define what we will use..

            def initialize bld
              @_build = bld
            end

            def list

              ca = @_build.current_attribute

              ca.writer_by_ do |atr|
                atr.__hello or ::Kernel.fail
                -> x, _oes_p do
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
          end

          class X_a_cma_m_A

            def self.with * x_a
              o = new
              _kp = self::ATTRIBUTES.init o, x_a
              _kp or self._SANITY
              o
            end

            attrs = Attributes.lib.call(
              foopie: :list,
              harbinger: nil,
            )

            attr_reader( * attrs.symbols )

            attrs.meta_attributes = X_a_cma_m_Mattrs
            attrs.attribute_class = X_a_cma_m_Attr

            const_set :ATTRIBUTES, attrs

            self
          end
        end
      end

    # ==
    # ==
  end
end
