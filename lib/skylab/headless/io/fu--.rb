module Skylab::Headless

  class IO::FU__  # :[#157] FileUtils reconceived as a controller-like "agent"
    # that is by default verbose whose output is bound to the proc passed
    # in its construction. ('p' will receive each message string.)

    include Headless_::Library_::FileUtils

    def initialize *a, & p
      p and a.push p
      @p = a.fetch( a.length - 1 << 1 )
    end

    ::FileUtils.collect_method( :verbose ).each do | meth_i |
      define_method meth_i do | *a, &p |
        h = ::Hash.try_convert a.last
        if ! h or ! h.key? :verbose
          fu_update_option a, verbose: true
        end
        super( * a, & p )
      end
    end

  private

    def fu_output_message msg
      @p[ msg ]
    end
  end
end
