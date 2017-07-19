module Skylab::System

  module Filesystem

    class File_Utils_Controller  # :[#011]

      # there is perhaps an improved variant of this in [br], subject-tagged.

      # NOTE nowadays we want to deprecate this for the sorts of reasons
      # explained in [#009.A]. but nonetheless:

        # this is FileUtils reconceived as a
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

      class << self

        def for_any_proc_ & x_p

          if x_p
            new_via( & x_p )
          else
            self
          end
        end

        alias_method :new_via, :new
        private :new
      end  # >>

      # <-

    include Home_.lib_.file_utils

    def initialize * a, & p
      p and a.push p
      @p = a.fetch( a.length - 1 << 1 )
    end

    ::FileUtils.collect_method( :verbose ).each do | meth_i |

      define_method meth_i do | *a, &p |

        h = ::Hash.try_convert a.last

        # neato - this changed in the jump from ruby 2.2.3 to 2.4.1 near named args
        if h
          if ! h.key? :verbose
            h[ :verbose ] = true  # change original - ick/meh
          end
        else
          a.push( verbose: true )
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
