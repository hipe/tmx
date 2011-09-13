require File.expand_path('../get', __FILE__)

module Skylab
  module Dependency
    class TaskTypes::TarballTo < TaskTypes::Get
      attribute :tarball_to
      attribute :from, :required => false
      attribute :get
      attribute :stem, :required => false
      def slake
        check_exists_nonzero and return true
        @get.kind_of?(String) or _fail("'get' must be string, had: #{get}")
        curl_or_wget_files or return false
        wrap_up
      end
    end
  end
end
