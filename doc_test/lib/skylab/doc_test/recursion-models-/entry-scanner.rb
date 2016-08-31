module Skylab::DocTest

  class RecursionModels_::EntryScanner

    class << self
      alias_method :via_path_, :new
      undef_method :new
    end  # >>

    def initialize path
      @_scn = Home_.lib_.string_scanner path
    end

    def pos= d
      @_scn.pos = d
    end

    def expect_one_separator__
      _d = @_scn.skip SEP_RX__
      _d || self._SANITY
    end

    def scan_entry
      @_scn.skip SEP_RX__
      @_scn.scan ENTRY_RX__
    end

    def eos?
      @_scn.eos?
    end

    same = ::Regexp.escape ::File::SEPARATOR
    SEP_RX__ = /#{ same }/
    ENTRY_RX__ = /[^#{ same }]+/
  end
end
