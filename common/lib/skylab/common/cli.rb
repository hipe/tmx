module Skylab::Common

  class CLI < Home_.lib_.brazen::CLI  # see [#018]

    def back_kernel
      self.class._application_kernel
    end

    Home_::Brazen_ = ::Skylab::Brazen  # EEK

    class << self

      def _application_kernel
        @___ak ||= Brazen_::Kernel.new Home_
      end
    end  # >>
  end
end
