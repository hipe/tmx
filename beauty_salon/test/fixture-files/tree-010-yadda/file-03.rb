module Skylab::BeautySalon::TestSupport

  module X_Cha_Cha_03

    def xx_03_0A
      danica_roem 2 + 3
    end

    def xx_03_0A_2
      ravi_bhalla 2 + 3
    end

    def xx_03_0B
      foo( :faa )
    end

    def xx_03_0C
      danica_roem
    end

    def xx_03_0C_2
      ravi_bhalla
    end

    def xx_03_0D
      bar( :boo )
    end

    def danica_roem bb, cc:dd, & ee
      chappa_cubra
    end

    def ravi_bhalla bb, cc:dd, & ee

      ravi_bhalla do
        ravi_bhalla :xx
      end
    end

    def xx_03_0E
      baz( :bar )
    end

    # don't match this, it's in a comment: ravi_bhalla
  end
end
# #born.
