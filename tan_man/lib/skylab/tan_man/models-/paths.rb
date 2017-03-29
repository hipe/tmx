module Skylab::TanMan

  class Models_::Paths

    # work in progress notes: this used to be (A) an "internal" action
    # implemented by using (B) a plain old proc that called this plain old
    # attributes-actor.
    #
    # as for (A), whatever this "internal" hack was can go away. action
    # exposures should be removed from modality clients with #masking and
    # that's it.
    #
    # as for (B), rather than do what we used to do which was use a plain
    # old proc to bridge the gap between our "framework" and our attributes-
    # actor, we would rather see if we can provide a tighter-yet-still-short
    # integration.
    #
    # exposing a plain old proc as an interface action was something [br]
    # accomplished by calling out to the [ba] "function as" node (where "as"
    # is the opposite of "via" - so any "foo via bar" could instead be named
    # "bar as foo"). this "as" node is wholly dedicated to adapting procs to
    # the [br] framework, and since [br] is going away in this regard, that
    # node should likewise evolve or sunset sometime soon.
    #
    # it was this remote node that did the validation of checking for
    # missing requireds. we can't use that node for this purpose because no
    # longer are we exposed as a simple proc; rather we are seeing what it
    # takes to expose an attributes actor as a microservice action.
    #
    # now, this node stands as an experimental sandbox that does whatever
    # it takes to pass the existing tests (for this UI node) implementing
    # this action as an attributes actor..

    # -

      Attributes_actor_.call( self,
        :path,
        :verb,

      ) do |o|  # (experimental weird means of specifying options here)

        o.is_required_by = -> _ivar_as_asc do
          true
        end
      end

      def initialize
        @__invocation_resources = yield.invocation_resources
      end

      # ~ ( this is what would abstract out if we found this pattern useful,
      #     that is if we wanted to expose attributes-actors as microservice
      #     actions generally..

      def to_bound_call_of_operator

        rsx = _invocation_resources_

        ok = as_attributes_actor_parse_and_normalize rsx.argument_scanner do |o|
          o.listener = rsx.listener
        end

        ok ? Common_::BoundCall.by( & method( :execute ) ) : NIL
      end

      # ~ )

      def execute

        m = :"execute__#{ @verb }__verb"
        if respond_to? m
          send m
        else
          when_bad_verb
        end
      end

      def execute__retrieve__verb
        m = :"retrieve__#{ @path }__path"
        if respond_to? m
          send m
        else
          when_bad_noun
        end
      end

      def when_bad_verb

        _listener.call :error, :unrecognized_verb do
          _build_common_event :unrecognized_verb, :verb, @verb, /\Aexecute__(.+)__verb\z/
        end

        NIL
      end

      def when_bad_noun

        _listener.call :error, :unknown_path do
          _build_common_event :unknown_path, :path, @path, /\Aretrieve__(.+)__path\z/
        end

        NIL
      end

      def _build_common_event sym, * sym_a, rx

        _i_a_ = self.class.public_instance_methods( false ).reduce [] do | m, i |
          md = rx.match i
          if md
            m.push md[ 1 ].intern
          end
          m
        end

        Common_::Event.inline_not_OK_with(
          sym,
          * sym_a,
          :term, sym_a.first,  # eew
          :did_you_mean, _i_a_,
        ) do |y, o|

          buff = o.terminal_channel_symbol.id2name.gsub UNDERSCORE_, SPACE_
          buff << SPACE_ << ick_oper( o.send o.term ) << ". did you mean "

          simple_inflection do
            oxford_join_do_not_store_count buff, Scanner_[ o.did_you_mean ], " or " do |x|
              ick_oper x
            end
          end

          buff << "?"
          y << buff
        end
      end

      def retrieve__generated_grammar_dir__path
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

        kn = Home_.lib_.system_lib::Filesystem::Normalizations::ExistentDirectory.via(
          :path, _app_tmpdir_path,
          :create_if_not_exist,
          :max_mkdirs, 2,   # you can make __tmx__ and you can make this path
          :filesystem, Home_.lib_.system.filesystem,

        ) do | * sym_a, & ev_p |

          p = _listener
          if p

            p.call( * sym_a ) do
              _ev = ev_p[]
              _ev.with_message_string_mapper MSG_MAP__
            end

            UNABLE_  # info events won't ride all the way out only errors

          elsif :info == sym_a.first
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

      def _listener
        _invocation_resources_.listener
      end

      def _invocation_resources_
        @__invocation_resources  # hi.
      end

      # ==

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
    # -

    # ==

    Actions = NOTHING_  # see [#pl-011.3]

    # ==
  end
end
# :#tombstone-A: used to be [br] proc-based action, and protected
