module Skylab::Basic::TestSupport

  module Tree

    def self.[] tcc
      tcc.include InstanceMethods___
    end  # >>

    module InstanceMethods___

    def via_paths_ * x_a
      Home_::Tree.via :paths, x_a
    end

    define_method :deindent_, -> do
      _RX = /^[ ]{8}/
      -> s do
        s.gsub! _RX, EMPTY_S_
        s
      end
    end.call

      def subject_module_
        Home_::Tree
      end
    end
  end
end

# #tombstone legacy artifacts of early early test setup
