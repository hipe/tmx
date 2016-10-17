module Skylab::TMX

  Attributes_ = ::Module.new

  module AttributesScratchSpace___

    module StandIn___

      def initialize x
        @pnode = x
      end

      def express_into y
        aval = @pnode.box[ self.class::KEY ]
        if aval
          x = aval.value_x
          if x.nil?
            y << SAY_NULL__
          else
            s = x.to_s
            if s.include? SPACE_
              y << s.inspect  # shyeah right
            else
              y << s
            end
          end
        else
          y << SAY_NONE__
        end
      end
    end

    class Attributes_::After
      include StandIn___
      KEY = "after"
    end

    class Attributes_::Category
      include StandIn___
      KEY = "category"
    end

    class Attributes_::DocTestManifest
      include StandIn___
      KEY = "doc test manifest"
    end

    is_lib = "is lib"
    say_is_lib = "lib"

    Attributes_::IsLib = -> parsed_node do

      ProcBasedSimpleExpresser_.new do |y|

        aval = parsed_node.box[ is_lib ]
        if aval
          if aval.value_x
            y << say_is_lib
          else
            y << SAY_NO__
          end
        else
          y << SAY_NONE__
        end
      end
    end

    class Attributes_::IsPotentiallyInterestingApplication
      include StandIn___
      KEY = "is potentially interesting application"
    end

    SAY_NO__ = 'no'
    SAY_NONE__ = '-'
    SAY_NULL__ = 'xxx'
  end
end
