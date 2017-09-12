module Skylab::Snag

  class Models_::ToDo

    class Actions::Melt  # see [#063]

      def definition ; [

        :glob, :property, :pattern,
        :default_by, -> _act do
          Common_::KnownKnown[ Here_.default_pattern_strings ]
        end,

        :glob, :property, :name,
        :description, -> y do
          y << "(see [#063]..)"
        end,
        :default_by, -> _act do
          Common_::KnownKnown[ [ "*#{ Autoloader_::EXTNAME }" ] ]
        end,

        :flag, :property, :dry_run,

        :property, :downstream_reference,

        :required, :glob, :property, :path,
      ] end

      # -

        def initialize
          extend ActionRelatedMethods_
          @_invocation_resources_ = yield
          init_action_ @_invocation_resources_
          @downstream_reference = @dry_run = nil  # #[#026]
        end

        def execute

          Session___.call_by do |o|
            o.is_dry = @dry_run
            o.downstream_reference = @downstream_reference
            o.filesystem_conduit = Home_.lib_.system.filesystem
            o.names = @name
            o.paths = @path
            o.patterns = @pattern
            o.system_conduit = Home_::Library_::Open3
            o.invocation_resources = @_invocation_resources_
            o.listener = _listener_
          end
        end
      # -

      # ==

      class Session___ < Common_::MagneticBySimpleModel

        def initialize
          yield self
          @be_verbose = true  # will probably go away
        end

        attr_writer(
          :downstream_reference,
          :filesystem_conduit,
          :invocation_resources,
          :is_dry,
          :listener,
          :names,
          :paths,
          :patterns,
          :system_conduit,
        )

        def execute
          ok = __resolve_collection
          ok &&= __resolve_file_unit_of_work_stream
          ok &&= __within_edit_session_flush_each_file_unit_of_work
          ok && __summarize
        end

        def __resolve_file_unit_of_work_stream

          __init_match_session
          __init_counts

          st = @_match_session.to_stream
          st &&= ___reduce_to_qualified_match_stream st
          st &&= __aggregate_to_file_unit_of_work_stream st
          if st
            @_file_unit_of_work_stream = st
            ACHIEVED_
          else
            st
          end
        end

        def __init_match_session

          @_match_session = Here_::Magnetics_::Collection_via_Arguments.define do |o|
            o.patterns = @patterns
            o.paths = @paths
            o.filename_patterns = @names
            o.system_conduit = @system_conduit
            o.listener = @listener
          end
          NIL
        end

        def __init_counts

          @_counts__number_of_seen_matches = 0
          @_counts__number_of_qualified_matches = 0
          NIL
        end

        def ___reduce_to_qualified_match_stream st

          st.reduce_by do | match |

            @_counts__number_of_seen_matches += 1

            yes = match.chomped_post_tag_string.length.nonzero?
            if yes
              @_counts__number_of_qualified_matches += 1
            end
            yes
          end
        end

        def __aggregate_to_file_unit_of_work_stream st

          p = nil
          _Unit_of_Work = __unit_of_work_prototype

          build_proc_for_when_match = -> match do

            @_counts__number_of_files_seen_here = 1

            current_path = match.path
            current_list = [ match ]

            flush_file_unit_of_work = -> do
              a = current_list
              current_list = nil
              _Unit_of_Work.new a, current_path
            end

            -> do

              begin

                match = st.gets

                if ! match
                  if current_list
                    x = flush_file_unit_of_work[]
                  end
                  break
                end

                if current_path == match.path
                  current_list ||= []
                  current_list.push match
                  redo
                end

                # match exists and is not of the same path

                @_counts__number_of_files_seen_here += 1

                x = flush_file_unit_of_work[]
                current_path = match.path

                break
              end while nil
              x
            end
          end

          p = -> do

            match = st.gets
            if match
              p = build_proc_for_when_match[ match ]
              p[]
            else
              match
            end
          end

          Common_.stream do
            p[]
          end
        end

        def __unit_of_work_prototype

          _sessioner = @__collection.sessioner_by do |o|
            o.is_dry = @is_dry
            o.listener = @listener
          end

          # _sessioner.downstream_reference = @downstream_reference

          This_::Models_::FileUnitOfWork.define do |o|
            o.is_dry = @is_dry
            o.filesystem_conduit = @filesystem_conduit
            o.listener = @listener
            o.sessioner = _sessioner
            o.system_conduit = @system_conduit
          end
        end

        def __within_edit_session_flush_each_file_unit_of_work

          st = @_file_unit_of_work_stream

          uow = st.gets
          if uow
            begin
              ok = uow.OMG_try
              ok || break
              uow = st.gets
              uow || break
              redo
            end while above
            ok
          else
            __when_no_file_units_of_work
          end
        end

        def __when_no_file_units_of_work

          @listener.call :info, :no_matches do

            __build_no_file_units_of_work_event
          end
          NIL
        end

        def __build_no_file_units_of_work_event

          Here_::Events_::No_Matches.with(
            :command, @_match_session.command,
            :patterns, @patterns,
            :number_of_matches, @_counts__number_of_seen_matches
          )
        end

        def __summarize

          @listener.call :info, :summary do
            Summary___.new(  # `new` with positional args is experimental [#co-070.2]
              @is_dry,
              @_counts__number_of_files_seen_here,
              @_counts__number_of_qualified_matches,
              @_counts__number_of_seen_matches,
            )
          end
          ACHIEVED_
        end

        def __resolve_collection
          if __resolve_downstream_reference
            __resolve_collection_via_downstream_reference
          end
        end

        def __resolve_collection_via_downstream_reference

          _ = Home_::Models_::NodeCollection.via_upstream_reference(
            @downstream_reference, @invocation_resources, & @listener )

          _store :@__collection, _
        end

        def __resolve_downstream_reference
          if @downstream_reference
            ACHIEVED_
          else
            _ = Home_::Models_::NodeCollection::Nearest_path.call(
              @paths.fetch( 0 ), @filesystem_conduit, & @listener )
            _store :@downstream_reference, _
          end
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==

      Summary___ = Common_::Event.prototype_with(
        :summary,
        :was_dry, false,
        :number_of_files_seen_here, nil,
        :number_of_qualified_matches, nil,
        :number_of_seen_matches, nil,
        :ok, true
      ) do |y, o|

        y << "#{ '(dryly) ' if o.was_dry }changed the #{
         }#{ np_ o.number_of_qualified_matches, 'qualified todo' } #{
          }of #{ np_ o.number_of_seen_matches, 'todo' } in #{
           }#{ np_ o.number_of_files_seen_here, 'file' }"
      end

      # ==

      Actions = nil
      This_ = self

      # ==
      # ==
    end
  end
end
