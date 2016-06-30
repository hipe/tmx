module Skylab::Task::TestSupport

  module Magnetics

    def self.[] tcc
      tcc.include self
    end

    # -

      def models_module_
        Home_::Magnetics::Models_
      end

    # -
  end
end
