module Skylab::TanMan
  module Sexp::Inflection end
  module Sexp::Inflection::InstanceMethods
    include ::Skylab::Autoloader::Inflection::InstanceMethods
    def symbolize nt_const
      nt_const.gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) do
        "_#{$1 || $2}"
      end.downcase.intern
    end
  end
end
