module Skylab::MetaHell

  class FUN::Parse::Field_

    module Int_

      Scan_token = -> tok do
        RX_ =~ tok and tok.to_i
      end
      RX_ = /\A\d+\z/

    end
  end
end
