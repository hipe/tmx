module Skylab::Snag
  module Models::Date

    valid_date_rx = %r{ \A \d{4} - \d{2} - \d{2} \z }x

    define_singleton_method :normalize do |x, error, info=nil|
      if valid_date_rx =~ x
        x
      else
        rs = error[ "invalid date: #{ x.inspect }" ]
        rs ? false : rs           # [#017]
      end
    end
  end
end
