module Skylab::Snag

  module Models::Date

    valid_date_rx = %r{ \A \d{4} - \d{2} - \d{2} \z }x

    define_singleton_method :normalize do |x, listener|
      if valid_date_rx =~ x
        x
      else
        ok = listener.receive_error_string "invalid date: #{ x.inspect }"
        ok ? UNABLE_ : ok  # :[#017]
      end
    end
  end
end
