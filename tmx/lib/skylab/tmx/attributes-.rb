module Skylab::TMX

  Attributes_ = ::Module.new

  class Attributes_::After

  end

  class Attributes_::Category

  end

  class Attributes_::DocTestManifest

  end

  is_lib = "is lib"
  say_is_lib = "lib"
  no = '-'

  Attributes_::IsLib = -> parsed_node do

    ProcBasedSimpleExpresser_.new do |y|

      if parsed_node.box[ is_lib ]
        y << say_is_lib
      else
        y << no
      end
    end
  end

  class Attributes_::IsPotentiallyInterestingApplication

  end
end
