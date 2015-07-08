module Skylab::Git

  module Models_::Branches

    module Modalities::CLI

      Actions = ::Module.new

      class Actions::ReNumber < Brazen_::CLI::Action_Adapter

        MUTATE_THESE_PROPERTIES =  [ :branch_name_stream ]

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
          #   2) read the branch names from STDIN. this argument interface
          #      is script-friendly, and is an appropriate idiom to support
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

          mfp.add :file, __build_file_property  # add this to the UI, and
            # we will reconcile it belwo

          NIL_
        end

        def prepare_backstream_call x_a

          # as for implementation of the numbered points in the previous
          # comment section (especially as it pertains to our UI policy):
          #
          #   • we added a `file` property. we must now nastily process it.
          #
          #   • we must manually process the presence of any
          #     non-interactive STDIN.
          #
          #   • we must UI validate mutex against the above two.
          #
          #   • in absence of either of the above 2, we default to (1)
          #
          #   • if (1) fails we need to issue an "unable" thru the UI

          if ! @resources.sin.tty?
            sin = @resources.sin
          end

          seen = @seen[ :file ]
          if seen
            d = seen.last_seen_index
            file = x_a[ d + 1 ]
            x_a[ d, 2 ] = EMPTY_A_  # eew
          end

          if sin
            if file
              __when_both
            else
              __prepare_etc_when_sin sin, x_a
            end
          elsif file
            __prepare_etc_when_file file, x_a
          else
            __prepare_etc_via_VCS x_a
          end
        end

        def __when_both

          prp = @front_properties.fetch :file
          io = stderr
          expression_agent.calculate do
            io.puts "STDIN and #{ par prp } are mutually exclusive."
          end
          output_invite_to_general_help
          maybe_use_exit_status Brazen_::CLI::GENERIC_ERROR
          UNABLE_
        end

        def __prepare_etc_when_sin sin, x_a

          x_a.push :branch_name_stream, _wrap_IO( sin )
          ACHIEVED_
        end

        # ~~ for file

        def __prepare_etc_when_file file, x_a

          _io = ::File.open file  # or etc
          _st = _wrap_IO _io
          x_a.push :branch_name_stream, _st
          ACHIEVED_
        end

        def _wrap_IO io

          Callback_.stream do
            io.gets
          end
        end

        def __build_file_property

          Brazen_::Model::Entity::Property.new do

            @name = Callback_::Name.via_variegated_symbol :file

            accept_description_proc -> y do
              y << "each line in file is a branch name (or use STDIN)"
            end
          end
        end

        # ~~ for vcs

        def __prepare_etc_via_VCS x_a

          _path = ::Dir.pwd
          _sc = @resources.system_conduit_

          bc = Home_::Models::Branch_Collection.via_project_path_and_cetera(
            _path,
            _sc,
            & handle_event_selectively
          )

          if bc

            # so yea, from front to back back to front we effectively
            # serialize and then un-serialze the same structure, but meh.

            _st = bc.to_stream.map_by do | branch_o |
              branch_o.name_string
            end
            x_a.push :branch_name_stream, _st
            ACHIEVED_
          else
            UNABLE_
          end
        end

        # ~

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
