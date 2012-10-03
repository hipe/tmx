module Skylab::TanMan
  module Sexp::Inflection end
  module Sexp::Inflection::InstanceMethods
    include ::Skylab::Autoloader::Inflection::InstanceMethods

    CHOMP_DIGITS_RX = /\A(?<stem>[^0-9]+)[0-9]+\z/

    def chomp_digits const
      _md = CHOMP_DIGITS_RX.match(const.to_s) or
        fail("sanity: Expecting this badbody to end in digits: #{const}")
      _md[:stem].intern
    end

    def symbolize nt_const
      nt_const.gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) do
        "_#{$1 || $2}"
      end.downcase.intern
    end
  end
end
