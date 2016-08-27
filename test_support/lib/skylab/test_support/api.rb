module Skylab::TestSupport

  module API

    # this node in its current form is something of an oddity: there is no
    # traditional (or any) API client exposed here (only for lack of interest
    # on our part). instead it only has a stowaway: the root autonomous
    # component system for [ts].
    #
    # this oddness stems from the the fact that [ts] itself is not an
    # application per se. if we reach a deeper understanding of [ts]'s
    # objective and scope as it pertains to interfaces, we might reconceive
    # what at first seemed odd as new patterns and norms.
    #
    # it is not the case that [ts] *is* an application. rather it happens to
    # house one or possibliy more utilities for which interfaces can be
    # arrived at. (we can omit from this discussion the test-runner clients
    # which have their own, isolated client implementations *and* interfaces
    # (as they should); but it is also the case that [ts] does not derive
    # its identity from these (all important) clients.)
    #
    # in service of these utilities, [ts] acts purely as a dumb (or close
    # enough to dumb) branch node that exposes these utilities.
    #
    # on the converse side of this, utilities need not concern themselves
    # with full-blown modality exposures. intead they can defer that work
    # to us simply by exposing a root ACS of their own.
    #
    # :#spot-ts-CLI (such as it is.)

    class Root_Autonomous_Component_System

      def initialize fs_p
        @_filesystem_proc = fs_p
      end

      def __ping__component_operation
        yield :description, -> y do
          y << 'pingzorzzs'
        end
        Ping___
      end

      def __file_coverage__component_operation( & yielder )

        @___fc_ACS ||= Home_::FileCoverage::Root_Autonomous_Component_System.
          by_filesystem( & @_filesystem_proc )

        @___fc_ACS.__file_coverage__component_operation( & yielder )
      end
    end

    Ping___ = -> & oes_p do
      oes_p.call :info, :expression, :ping do |y|
        y << "pong from #{ highlight '[ts]' }!"
      end
      NOTHING_
    end
  end
end
