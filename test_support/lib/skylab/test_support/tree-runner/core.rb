module Skylab

  module TestSupport

    class Tree_Runner

      def initialize _, o, e, a, env

        @argv = a
        @resources = Resources___.new o, e, a, env
        @_was_unable = false
      end

      attr_writer :sidesystem_load_ticket_stream_proc

      Resources___ = ::Struct.new :sout, :serr, :argv, :environment_variables

      def execute
        __init_callback_handler
        ok = __load_and_start_coverage_plugin_if_necessary
        ok &&= __resolve_bound_call
        ok and begin
          ok = @bc.receiver.send @bc.method_name, * @bc.args
          ok or _when_not_OK ok
        end
      end

      def __init_callback_handler

        # a custom event callback handler similar to [#ca-006].
        # as part of what is here a broader pattern we implement :+[#br-023]

        @on_event_selectively = -> * i_a, & ev_p do

          first_two = i_a[ 0, 2 ]  # `error`, `string`

          rest = i_a[ 2 .. -1 ]  # `authentication_failure`, `user`

          long_a = rest.reverse
          long_a.concat first_two  # `__receive__user_authentication_failure_error_string__`

          m = :"__receive__#{ long_a * UNDERSCORE_ }__"

          if ! respond_to? m
            m = :"__receive__#{ first_two * UNDERSCORE_ }__"
            args = rest
          end

          send m, * args, & ev_p  # result is result
        end
        nil
      end

      def __resolve_bound_call

        @dsp = __build_dispatcher
        @bc = @dsp.bound_call_via_ARGV @argv
        if @bc
          ACHIEVED_
        else
          _when_not_OK @bc
        end
      end

      def _when_not_OK x
        if @_was_unable
          __invite
        end
        x
      end

      def __build_dispatcher

        require_relative 'plugin-'  # no a.l for now..

        disp = Tree_Runner_::Plugin_::Dispatcher.new @resources, & @on_event_selectively

        disp.state_machine(

          :started, :finish, :finished,

          :started, :build_sidesystem_tree, :produced_sidesystem_tree,

          :produced_sidesystem_tree,
          :flush_the_sidesystem_tree,
          :finished,

          :produced_sidesystem_tree,
          :reduce_the_sidesystem_tree,
          :produced_sidesystem_tree,

          :produced_sidesystem_tree,
          :build_the_test_files,
          :produced_the_test_files,

          :produced_the_test_files,
          :reduce_the_test_files,
          :produced_the_test_files,

          :produced_the_test_files, :flush_the_test_files, :finished )

        disp.load_plugins_in_module Plugins__

        disp
      end

      # ~ callbacks where we receive data:

      def __receive__from_plugin_sidesystem_box__ & o_p
        @SS_bx = o_p[]
        @SS_bx && ACHIEVED_
      end

      def __receive__from_plugin_test_file_stream__ & o_p
        @test_file_stream = o_p[]
        @test_file_stream && ACHIEVED_
      end

      # ~ callbacks where we give data:

      def __receive__for_plugin_adapter__ sym
        h = ( @__vendor_adapters__ ||= {} )
        h.fetch sym do
          h[ sym ] = __build_adapter sym  # memoizing any failure
        end
      end

      def __receive__for_plugin_dispatcher__
        @dsp
      end

      def __receive__for_plugin_program_name__
        _program_name
      end

      def __receive__for_plugin_sidesystem_stream_proc__
        @sidesystem_load_ticket_stream_proc
      end

      def __receive__for_plugin_sidesystem_box__
        @SS_bx
      end

      def __receive__for_plugin_test_file_stream__
        @test_file_stream
      end

      # ~ event handlers for specific events from expecific plugins:

      def __receive__help_event__ & ev_p

        _render_into_stderr_event ev_p[]
      end

      # ~ general event callbacks:

      def __receive__error_expression__ *, & y_p

        _expression_agent.calculate _serr_yielder, & y_p
        @_was_unable = true
        nil
      end

      def __receive__error_event__ *, & ev_p

        _receive_error_event ev_p[]
      end

      def __receive__error_invalid_property_value__ & ev_p

        _receive_error_event ev_p[]
      end

      def __receive__info_expression__ & y_p

        _expression_agent.calculate _serr_yielder, & y_p
        nil
      end

      def __receive__optparse_parse_error_exception__ & ev_p
        __receive_error_exception ev_p[]
      end

      # ~ support for above

      def _receive_error_event ev
        _render_into_stderr_event ev
        @_was_unable = true
        UNABLE_
      end

      def __receive_error_exception e
        @resources.serr.puts e.message
        @_was_unable = true
        UNABLE_
      end

      def __invite  # watch for unification opportunities with [#ba-038]
        @resources.serr.puts "try `#{ _program_name } --help` for help"
        nil
      end

      def _program_name
        ::File.basename $PROGRAM_NAME
      end

      def _render_into_stderr_event ev

        ev.express_into_under _serr_yielder, _expression_agent
        nil
      end

      def _expression_agent
        @__expag__ ||= Expression_Agent___.new
      end

      def _serr_yielder
        ::Enumerator::Yielder.new do | line |
          @resources.serr.puts line
        end
      end

      # ~ support for above (ad-hoc business)

      def __build_adapter sym

        _cls = Tree_Runner_::Adapters_.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const, false )

        _cls.new @resources, & @on_event_selectively
      end

      # ~ outside the main flow: coverage specifics

      def __load_and_start_coverage_plugin_if_necessary  # [#002] ..

        d = @argv.index COVERAGE_SWITCH___
        if d
          ok = __load_and_start_the_coverage_plugin d
          ok or _when_not_OK ok
        else
          true
        end
      end

      def __load_and_start_the_coverage_plugin d

        require "#{ HERE_ }/plugins--/express-coverage"

        pu = Plugins__::Express_Coverage::Back.
          new( @resources, & @on_event_selectively )

        pu.ARGV = @argv
        pu.ARGV_coverage_switch_index = d

        pu.execute
      end

      COVERAGE_SWITCH___ = '--coverage'

      # ~


    class Expression_Agent___  # #todo after :+#dev cull this

      alias_method :calculate, :instance_exec

      # ~ style-related classifications

      def _curry x
        Home_.lib_.brazen::CLI_Support::Styling::Stylify.curry[ [ * x ] ]
      end

      def ick msg  # e.g divide
        "\"#{ msg }\""
      end

      def hdr msg  # e.g help
        ( @hdr ||= _curry :green )[ msg ]
      end

      def par x  # e.g divide

        _nm = if x.respond_to?( :ascii_only? ) || x.respond_to?( :id2name )
          Callback_::Name.via_slug x
        else
          x.name
        end

        "<#{ _nm.as_slug }>"
      end

      # ~ linguistic- (and EN-) related classifications of string

      def sp_ * x_a

        x_a.push :syntactic_category, :sentence_phrase

        _fr = Home_.lib_.human::NLP::EN.expression_frame_via_iambic x_a

        _fr.express_into ""
      end

      def and_ s_a
        # #covered-by: in tree runner, list files and do counts
        Callback_::Oxford_and[ s_a ]
      end

      def both x
        # #covered-by: same as above
        Home_.lib_.human::NLP::EN.both x
      end

      def indefinite_noun s
        self._WHERE
        _NLP_agent.indefinite_noun[ s ]
      end

      def or_ s_a
        Callback_::Oxford_or[ s_a ]
      end

      def progressive_verb s
        _inflect_first_word s, :progressive_verb
      end

      def s * x_a
        Home_.lib_.human::NP::EN.s( * x_a )
      end

      def third_person s
        self._WHERE
        _inflect_first_word s, :third_person
      end

      def val x
        x.inspect
      end

      def _inflect_first_word s, m

        s_a = s.split SPACE_
        s_a[ 0 ] = _NLP_agent.send m, s_a.fetch( 0 )
        s_a * SPACE_
      end

      def _NLP_agent
        Home_.lib_.human::NLP::EN::POS
      end
    end

      HERE_ = ::File.expand_path '..', __FILE__

      Plugins__= ::Module.new

      Tree_Runner_ = self

      UNDERSCORE_ = '_'.freeze  # we need our own because [#002]
    end
  end
end
