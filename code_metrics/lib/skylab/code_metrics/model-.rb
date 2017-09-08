module Skylab::CodeMetrics

  Require_brazen_[]  # might not be necessary for production, but is for viz

  Model_ = ::Module.new
  module Model_::Support  # #[#sl-155] scope stack trick

    My_Entity__ = Brazen_::Modelesque::Entity

    class Report_Action < Brazen_::ActionToolkit

      class << self

        def entity_enhancement_module
          My_Entity__
        end
      end  # >>

    private

      def build_find_files_command_via_paths_ path_a

        h = @argument_box.h_

        Home_.lib_.system.find(

          :paths, path_a,
          :ignore_dirs, h.fetch( :exclude_dir ),
          :filenames, h[ :include_name ],
          :freeform_query_infix_words, %w'-not -type d',
          :when_command, IDENTITY_

        ) do | * i_a, & ev_p |

          if :info != i_a.first
            @on_event_selectively.call( * i_a, & ev_p )
          end
        end
      end

      def stat_and_exception_ path  # :+[#sy-021]

        stat = begin
          e = nil
          filesystem_conduit_.stat path
        rescue ::Errno::ENOENT => e
          false
        end
        [ stat, e ]
      end

      def maybe_send_event_about_noent_ e

        @on_event_selectively.call :info, :enoent do

          Common_::Event::Via_exception.via(
            :exception, e,
            :path_hack,
            :terminal_channel_symbol, :enoent,
          )
        end
        NIL_
      end

      def line_upstream_via_system_command_ a

        _ = Home_::Magnetics_::Line_Upstream_via_System_Command
        o = _.new( & @on_event_selectively )
        o.system_command_string_array = a
        o.system_conduit = system_conduit_
        o.execute
      end

      def filesystem_conduit_
        Home_.lib_.system.filesystem
      end

      def system_conduit_
        Home_.lib_.open_3
      end
    end

    _ = Brazen_::CommonAssociations::LEGACY

    COMMON_PROPERTIES = _.new My_Entity__ do | sess |

      sess.edit_common_properties_module(

        :description, -> y do

          y << "directories whose basename matches this pattern will #{
            }be skipped."

          y << "adding more patterns narrows the search."

          y << "the default is to skip directories whose name begins #{
            }with a dot ('.*')."

          y << "(ETC explain the thing with the '[]')"

        end,

        :argument_arity, :zero_or_more,

        :ad_hoc_normalizer, -> qkn, & oes_p do
          a = qkn.value
          if '[]' == a.last
            a.clear  # EGADS!
          end
          Common_::KnownKnown[ a ]
        end,

        :default, [ '.*' ],

        :property, :exclude_dir,


        :description, -> y do

          y << "e.g. --name='*.rb'. When present, this limits the files"
          y << 'reported on to those that match the pattern(s).'
          y << 'adding more patterns broadens the search (OR not AND).'
          y << 'this option is only relevant on directories.'
        end,

        :argument_arity, :zero_or_more,

        :property, :include_name,


        :description, -> y do
          y <<  "whether or not to actually run the report (dry-run-esque)"
        end,
        :flag,
        :default, false,
        :property, :skip_report,
      )
    end
  end
end
