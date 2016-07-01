module Skylab::Task::TestSupport

  module Magnetics

    def self.[] tcc, sym=nil
      tcc.include self
      if sym
        _mod = Autoloader_.const_reduce [ sym ], Here_
        _mod[ tcc ]
      end
    end

    # -

      def magnetics_module_
        Home_::Magnetics::Magnetics_
      end

      def models_module_
        Home_::Magnetics::Models_
      end

    # -

    Here_ = self
  end
end
