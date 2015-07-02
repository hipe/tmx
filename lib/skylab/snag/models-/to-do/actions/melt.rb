module Skylab::Snag

  class Models_::To_Do

    class Actions::Melt  # see [#063]

      Home_.lib_.brazen::Model.common_entity( self,

        :default_proc, -> do
          To_Do_.default_pattern_strings
        end,
        :argument_arity, :one_or_more, :property, :pattern,


        :description, -> y do
          y << "(see [#063]..)"
        end,
        :default_proc, -> do
          [ "*#{ Autoloader_::EXTNAME }" ]
        end,
        :argument_arity, :one_or_more, :property, :name,


        :flag, :property, :dry_run,

        :property, :downstream_identifier,

        :required, :argument_arity, :one_or_more, :property, :path
      )

      def produce_result

        h = @argument_box.h_

        o = Session___.new @kernel, & handle_event_selectively

        o.is_dry = h[ :dry_run ]
        o.downstream_identifier = h[ :downstream_identifier ]
        o.filesystem_conduit = Home_.lib_.system.filesystem
        o.names = h[ :name ]
        o.paths = h[ :path ]
        o.patterns = h[ :pattern ]
        o.system_conduit = Home_::Library_::Open3

        o.execute
      end

      class Session___

        def initialize kr, & x_p

          @be_verbose = true  # will probably go away

          @is_dry = nil
          @_kernel = kr
          @_oes_p = x_p
        end

        attr_writer(
          :downstream_identifier,
          :filesystem_conduit,
          :is_dry,
          :names,
          :paths,
          :patterns,
          :system_conduit
        )

        def execute

          ok = __resolve_collection
          ok &&= __resolve_file_unit_of_work_stream
          ok &&= __within_edit_session_flush_each_file_unit_of_work
          ok && __summarize
        end

        def __resolve_collection

          if ! @downstream_identifier

            path = Home_::Models_::Node_Collection.nearest_path(
              @paths.fetch( 0 ), @filesystem_conduit, & @_oes_p )

            if path
              @downstream_identifier = path
            else
              ok = path
            end
          end

          if @downstream_identifier
            __via_downstream_identifier_resolve_collection
          else
            ok
          end
        end

        def __via_downstream_identifier_resolve_collection

          col = Home_::Models_::Node_Collection.new_via_upstream_identifier(
            @downstream_identifier, & @_oes_p )
          if col
            @_collection = col
          else
            col
          end
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

          o = To_Do_::Sessions_::Collection.new( & @_oes_p )

          o.filename_pattern_s_a = @names
          o.path_s_a = @paths
          o.pattern_s_a = @patterns
          o.system_conduit = @system_conduit
          @_match_session = o
          NIL_
        end

        def __init_counts

          @_counts__number_of_seen_matches = 0
          @_counts__number_of_qualified_matches = 0

          NIL_
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

          sr = @_collection.start_sessioner( & @_oes_p )
          sr.is_dry = @is_dry

          # sr.downstream_identifier = @downstream_identifier

          _Unit_of_Work = Melt_::Models_::File_Unit_of_Work.new_prototype do | o |
            o.is_dry = @is_dry
            o.filesystem_conduit = @filesystem_conduit
            o.kernel = @_kernel
            o.on_event_selectively = @_oes_p
            o.sessioner = sr
            o.system_conduit = @system_conduit
          end

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

          Callback_.stream do
            p[]
          end
        end

        def __within_edit_session_flush_each_file_unit_of_work

          st = @_file_unit_of_work_stream

          uow = st.gets
          if uow
            begin
              ok = uow.OMG_try
              ok or break
              uow = st.gets
              uow or break
              redo
            end while nil
            ok
          else
            __when_no_file_units_of_work
          end
        end

        def __when_no_file_units_of_work

          @_oes_p.call :info, :no_matches do

            __build_no_file_units_of_work_event
          end
          NIL_
        end

        def __build_no_file_units_of_work_event

          To_Do_::Events_::No_Matches.new_with(
            :command, @_match_session.command,
            :patterns, @patterns,
            :number_of_matches, @_counts__number_of_seen_matches
          )
        end

        def __summarize

          @_oes_p.call :info, :summary do

            Summary___[
              @is_dry,
              @_counts__number_of_files_seen_here,
              @_counts__number_of_qualified_matches,
              @_counts__number_of_seen_matches ]
          end
          ACHIEVED_
        end
      end

      Summary___ = Callback_::Event.prototype_with(
        :summary,
        :was_dry, false,
        :number_of_files_seen_here, nil,
        :number_of_qualified_matches, nil,
        :number_of_seen_matches, nil,
        :ok, true
      ) do | y, o |

        y << "#{ '(dryly) ' if o.was_dry }changed the #{
         }#{ np_ o.number_of_qualified_matches, 'qualified todo' } #{
          }of #{ np_ o.number_of_seen_matches, 'todo' } in #{
           }#{ np_ o.number_of_files_seen_here, 'file' }"
      end

      Autoloader_[ Melt_ = self,  # because [#026]
        ::File.join(
          ::File.dirname( __FILE__ ),
          ::File.basename( __FILE__, Autoloader_::EXTNAME ) ) ]
    end
  end
end
