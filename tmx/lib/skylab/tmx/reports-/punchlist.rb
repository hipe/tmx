module Skylab::TMX

  class Reports_::Punchlist

    def initialize & emit
      @_emit = emit
    end

    def execute

      lines = []
      lines << "# first three"
      lines << "adder"
      lines << ""
      lines << "# second group"
      lines << "dora"
      lines << "gilius"
      lines << ""
      lines << "# third three"
      lines << "stern"
      _st = Stream_[ lines ]
      _st
    end
  end
end
# #history: born to replace #tombstone: the static punchlist.template
