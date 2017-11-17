require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] custom meta associations! - manually" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

      context "for example if you wanted a \"list\"-style (`argument_arity` many)" do  # #cov2.12

        it "ok." do
          o = _cls.with :foopie, :x, :foopie, :y, :harbinger, :j, :foopie, :z
          o.foopie.should eql [ :x, :y, :z ]
          o.harbinger.should eql :j
        end

        shared_subject :_cls do

          class X_cma_m_MyCustomAssociation < Home_::CommonAssociation

            # if you want a custom association class, you probably want to
            # subclass so you can use the producer/consumer/interpreter
            # customization API that is part of our "common" class..

            # we don't actually do anything interesting here, except
            # demonstrate that it is this class that is used.

            def HELLO_MY_CUSTOM_ASSOC
              NIL
            end
          end

          # ==

          module X_cma_m_MyCustomMetaAssociations  # (we will only define what we use)

            def list

              @_association_.argument_value_consumer_by_ do |asc|

                asc.HELLO_MY_CUSTOM_ASSOC

                ivar = asc.as_ivar  # be careful doing it here (what if ivar name changed later in the meta assocs?)

                -> x, _p do

                  ent = @_normalization_.entity

                  if ent.instance_variable_defined? ivar
                    a = ent.instance_variable_get ivar
                  else
                    a = []
                    ent.instance_variable_set ivar, a
                  end

                  a.push x
                  KEEP_PARSING_
                end
              end
            end

            # --
            # --
          end

          # ==

          class X_cma_m_MyCustomEntity

            class << self
              def with * x_a
                o = new
                _kp = self::ATTRIBUTES.init o, x_a
                _kp or self._SANITY
                o
              end
            end  # >>

            attrs = Attributes.lib.call(
              foopie: :list,
              harbinger: nil,
            )

            attr_reader( * attrs.symbols )

            attrs.meta_associations_module = X_cma_m_MyCustomMetaAssociations
            attrs.association_class = X_cma_m_MyCustomAssociation

            const_set :ATTRIBUTES, attrs

            self
          end
        end
      end

    # ==
    # ==
  end
end
