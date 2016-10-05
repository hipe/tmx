module Skylab::Common

  class CLI < Home_.lib_.brazen::CLI  # see [#018]

    def back_kernel
      self.class.application_kernel_
    end

    Home_::Brazen_ = ::Skylab::Brazen  # EEK

    class << self

      def application_kernel_
        @___ak ||= __build_application_kernel
      end

      def __build_application_kernel

        # rather than write a stowaway entry at the top file in the
        # universe, we load this narrow stem manually. :#spot-3

        _load_path = ::File.join Home_.dir_path, 'models-/event/actions/fire.rb'

        ::Kernel.load _load_path

        Brazen_::Kernel.new Home_
      end
    end  # >>
  end
end
