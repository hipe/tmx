module Skylab::Fields::TestSupport

  module Attributes::Stack

    module Common_Frame

      class << self
        def [] tcc
          tcc.include self
        end
      end  # >>

      Subject_ = -> * a do
        Subject_module_[].call_via_arglist a
      end

      Subject_module_ = -> do
        Home_::Attributes::Stack::Common_Frame
      end

      Here_ = self
    end
  end
end
