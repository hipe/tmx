module Skylab::Git

  module Models_::Branches

    module Modalities::CLI

      Actions = ::Module.new

      class Actions::ReNumber < Brazen_::CLI::Action_Adapter

        MUTATE_THESE_PROPERTIES =  [ :branch_name_stream ]

        # ~ converge three inputs into one backbound argument

        def mutate__branch_name_stream__properties

          # the back only cares about having a stream of branch names.
          # from the front, we facilitate 3 ways of producing this stream:
          #
          #   1) use the VCS to report branches for the presumed project
          #      that we are "inside" of per the process's `pwd`. this
          #      arg-interface is the most user-friendly for the typical
          #      use case, but is decidedly *not* something the back should
          #      concern itself with.
          #
          #   2) read the branch names from STDIN. this script-friendly
          #      argument interface is the idiomatic choice-of-least-surprise
          #      for this modality.
          #
          #   3) read the branch names as lines of a file. this is an
          #      essential debugging feature. whether or not it has general
          #      utility is peripheral. (the same effect can be derived
          #      trivally from (2), unless you also want to use interactive
          #      debugging (we do), which must occupy STDIN for itself.)
          #
          # (comments in the next method build important points from these.)

          mfp = mutable_front_properties

          mfp.remove :branch_name_stream  # hide this from the UI, although
            # below we must still operate knowing it is there and required.

          _prp = build_property :file, :description, -> y do
            y << "each line in file is a branch name (or use STDIN)"
          end

          mfp.add :file, _prp  # add this to the UI, and
            # we will reconcile it below

          NIL_
        end

        def prepare_backstream_call x_a

          # as for implementation of the numbered points in the previous
          # comment section (especially as it pertains to our UI policy):
          #
          #   • do [#sy-022.A] the common normalization for stdin and file.
          #
          #   • if we get a valid neither from the above, we default to (1)
          #
          #   • if (1) fails we need to issue an "unable" thru the UI

          st = __produce_name_stream
          if st
            x_a.push :branch_name_stream, st
            ACHIEVED_
          else
            st
          end
        end

        def __produce_name_stream

          _path_arg = remove_backstream_argument_argument :file

          kn = Home_.lib_.system.filesystem( :Upstream_IO ).with(
            :instream, @resources.sin,
            :path_arg, _path_arg,
            :neither_is_OK,
            & handle_event_selectively
          )

          if kn
            if kn.is_known
              kn.value_x.to_simple_line_stream
            else

              # the argument value is a known unknown, that is, the user
              # wants us to use neither STDIN nor a file, so:

              __produce_name_stream_via_VCS
            end
          else
            kn  # e.g mutex failure on STDIN & file
          end
        end

        def __produce_name_stream_via_VCS

          _path = @resources.bridge_for( :filesystem ).pwd
            # we can work with the pwd from the current modality ONLY

          _sc = @resources.bridge_for :system_conduit

          bc = Home_::Models::Branch_Collection.via_project_path_and_cetera(
            _path,
            _sc,
            & handle_event_selectively
          )

          if bc

            # so yea, from front to back back to front we effectively
            # serialize and then un-serialze the same structure, but meh.

            bc.to_stream.map_by do | branch_o |
              branch_o.name_string
            end
          else
            bc
          end
        end

        # ~ hack o.p

        def bound_call_from_parse_options

          # supreme hack to stop platform o.p from parsing the minus sign:
          # remove then replace the last term of ARGV IFF it looks like the
          # subject term (because otherwise the platform o.p will try to
          # parse it as an option and fail). but keep in mind you want
          # something like `-h` to pass thru.

          argv = send :argv

          if argv.length.nonzero? && /\A-[0-9]/ =~ argv.last
            do_this = true
            term = argv.pop
          end

          bc = super  # (is nil on success)

          if do_this
            argv.push term
          end
          bc
        end
      end
    end
  end
end
