module Skylab::Headless

  class IO::FU                    # a FileUtils controller that is always
                                  # verbose, output is bound to some func

    include Headless::Services::FileUtils

    ::FileUtils.collect_method( :verbose ).each do |name|
      define_method( name ) do |*args, &block|
        super( *fu_update_option( args, verbose: true ), &block )
      end
    end

  protected

    def initialize f
      @f = f
    end

    def fu_output_message msg
      @f[ msg ]
    end
  end
end
