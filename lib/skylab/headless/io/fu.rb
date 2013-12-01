module Skylab::Headless

  class IO::FU  # FileUtils reconceived as a controller-like "agent"
    # that is by default verbose whose output is bound to the proc passed
    # in its construction. ('p' will receive each message string.)

    include Headless::Services::FileUtils

    def initialize p
      @p = p
    end

    ::FileUtils.collect_method( :verbose ).each do | meth_i |
      define_method meth_i do | *a, &p |
        if (( h = ::Hash.try_convert a.last )) and ! h.key? :verbose
          fu_update_option a, verbose: true
        end
        super( * fu_update_option( a, verbose: true ), & p )
      end
    end

  private

    def fu_output_message msg
      @p[ msg ]
    end
  end
end
