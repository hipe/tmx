module Skylab::System

  class Services___::Filesystem

    class File_Utils_Controller__  # :[#157] FileUtils reconceived as a..

        # controller-like "agent" that is by default verbose whose output
        # is bound to the argument proc used in its construction. send the
        # familiar FU messages to the controller (mkdir etc). the argument
        # proc will receive each message string that FU generates during
        # the course of the controller's lifetime.
        #
        # this frees your class from having to pollute its ivar namespace,
        # method namespace and ancestor chain with fileutils; freeing your
        # objects of these side-effects by allowing them to focus the event
        # wiring into fileutils into one place.

      # <-

    include Home_.lib_.file_utils

    def initialize * a, & p
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
  # ->
    end
  end
end
