module Skylab::TestSupport

  module Quickie

    module Models_::Specify

      class << self

        def apply_if_not_defined test_context_class
          if ! test_context_class.respond_to? :specify
            test_context_class.send :define_singleton_method, :specify, SPECIFY__
            test_context_class.send :define_method, :should, SHOULD__ ; nil
          end
        end
      end

        SPECIFY__ = -> & p do
          @specify_describing_proxy_class ||= Build_describing_proxy_class[ self ]
          pxy = @specify_describing_proxy_class.new
          if pxy.class.const_defined? :BEFORE_EACH_PROC_  # hacked for now
            pxy.instance_exec( & pxy.class::BEFORE_EACH_PROC_ )
          end
          pxy.instance_exec( & p )
          it "#{ pxy.s_a * AND__ }" do  # or `description` if you want to repeat it
            instance_exec( & p )  # or do it directly
          end
          nil
        end

        SHOULD__ = -> x do
          subject.should x
        end

      Build_describing_proxy_class = -> test_context_class do
        cls = ::Class.new test_context_class
        cls.include Methods_for_Test_Context_as_Predicator___
        cls
      end

      module Methods_for_Test_Context_as_Predicator___

        def initialize
          @s_a = []
          super :___description_contexts_should_not_need_a_runtime___
        end
        attr_reader :s_a

        def should x
          @s_a.push x
        end

        def eql x
          "will equal #{ x }"
        end
      end

      AND__ = ' and '.freeze

    end
  end
end
