module Skylab::DocTest

  module Models_::Description_String
    # -
      # -
        class << self

          def [] str

            # lifted directly from [#003]

            s = str.dup
            s.sub! TRAILING_RX__, EMPTY_S_
            s.sub! SO_RX__, EMPTY_S_
            s.sub! IT_RX__, EMPTY_S_
            s.sub! ITS_RX__, "is "
            s

          end

          IT_RX__ = /\Ait /i
          ITS_RX__ = /\Ait's /i
          SO_RX__ = /\A(?:so|then),? /i
          TRAILING_RX__ = /[:,]?\r?\n?\z/

        end
      # -
    # -
  end
end
