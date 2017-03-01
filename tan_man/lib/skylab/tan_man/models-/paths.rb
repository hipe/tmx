module Skylab::TanMan

  module Models_::Internal_

    # :+[#br-013]:API.A trailing underscore = not part of reactive model tree)

    class Paths

      # reminder: there is no magic here, no API affiliations. this is just
      # a plain old actor implementing an action internally whose surface
      # form is a proc with corresponding parameters as the below four.

      Attributes_actor_.call( self,
        :path_x,
        :verb_x,
        :call,
      )

      Common_::Event.selective_builder_sender_receiver self

      def initialize & p
        @on_event_selectively = p
      end

      def execute

        m = :"execute_#{ @verb_x }_verb"
        if respond_to? m
          send m
        else
          when_bad_verb
        end
      end

      def execute_retrieve_verb
        m = :"retrieve_#{ @path_x }_path"
        if respond_to? m
          send m
        else
          when_bad_noun
        end
      end

      def when_bad_verb

        @on_event_selectively.call :error, :unrecognized_verb do
          _build_common_event :unrecognized_verb, :verb, @verb_x, /\Aexecute_(.+)_verb\z/
        end

        UNABLE_
      end

      def when_bad_noun

        @on_event_selectively.call :error, :unknown_path do
          _build_common_event :unknown_path, :path, @path_x, /\Aretrieve_(.+)_path\z/
        end

        UNABLE_
      end

      def _build_common_event sym, * i_a, rx

        _i_a_ = self.class.public_instance_methods( false ).reduce [] do | m, i |
          md = rx.match i
          if md
            m.push md[ 1 ].intern
          end
          m
        end

        _term = /[^_]+\z/.match( sym )[ 0 ]

        build_not_OK_event_with sym,
            * i_a, :term, _term, :did_you_mean, _i_a_ do | y, o |

          _s_a = o.did_you_mean.map do | x |
            ick x
          end

          y << "#{ Common_::Name.via_variegated_symbol( o.terminal_channel_i ).as_human } #{
            }#{ ick o.send( o.term ) }. did you mean #{ or_ _s_a }?"
        end
      end

      def retrieve_generated_grammar_dir_path
        td = Memoized_GGD_tmpdir__[]
        td ||= Memoize_GGD_tmpdir__[ build_GGD_tmpdir ]
        td and td.to_path
      end

      -> do
        _TMPDIR = nil
        Memoized_GGD_tmpdir__ = -> { _TMPDIR }
        Memoize_GGD_tmpdir__ = -> tmpdir do
          _TMPDIR = tmpdir
        end
      end.call

      def build_GGD_tmpdir

        _app_tmpdir_path = app_tmpdir_path

        kn = Home_.lib_.system.filesystem( :Existent_Directory ).call_via(
          :path, _app_tmpdir_path,
          :create_if_not_exist,
          :max_mkdirs, 2   # you can make __tmx__ and you can make this path

        ) do | * i_a, & ev_p |

          if @on_event_selectively

            @on_event_selectively.call( * i_a ) do
              _ev = ev_p[]
              _ev.with_message_string_mapper MSG_MAP__
            end

            UNABLE_  # info events won't ride all the way out only errors

          elsif :info == i_a.first
            # nothing, for now
           else
            raise ev_p[].to_exception
          end
        end

        if kn
          kn.value_x
        else
          kn
        end
      end

      MSG_MAP__ = -> s, line_index, * do
        if line_index.zero?
          "#{ highlight 'while resolving [tm] generated grammar dir' }: #{ s }"
        else
          s
        end
      end

      def app_tmpdir_path

        lib = Home_.lib_

        ::File.join lib.dev_tmpdir_path, lib.tmpdir_stem
      end
    end
  end
end