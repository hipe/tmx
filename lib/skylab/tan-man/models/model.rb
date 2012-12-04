module Skylab::TanMan
  class Models::Model # at [#040] sub client
    extend MetaHell::DelegatesTo
    extend Porcelain::Attribute::Definer

  protected

    def initialize request_client
      fail "check me - is it time yet?"
      @request_client = request_client
    end

    def emit *a
      @request_client.emit(* a)
    end
  end
end
