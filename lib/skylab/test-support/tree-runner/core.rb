module Skylab

  module TestSupport

    class Tree_Runner

      def initialize _, o, e, a

        @resources = Resources___.new o, e
        @was_unable = false
        if a.frozen?
          @argv = a
        else
          @argv = a.dup.freeze  # #todo remove after :+#dev
        end
      end

      Resources___ = ::Struct.new :sout, :serr

      attr_accessor :root_directory_path

      def execute
        ok = __load_and_start_coverage_plugin_if_necessary
        ok &&= __resolve_bound_call
        ok and begin
          ok = @bc.receiver.send @bc.method_name, * @bc.args
          ok or __when_not_OK ok
        end
      end

      def __resolve_bound_call

        @dsp = __build_dispatcher
        @bc = @dsp.bound_call_via_ARGV @argv
        if @bc
          ACHIEVED_
        else
          __when_not_OK @bc
        end
      end

      def __when_not_OK x
        if @was_unable
          __invite
        end
        x
      end

      def __load_and_start_coverage_plugin_if_necessary  # [#002] ..

        if @argv.index COVERAGE_SWITCH_
          __load_and_start_the_coverage_plugin
        else
          true
        end
      end

      COVERAGE_SWITCH_ = '--coverage'

      def __load_and_start_the_coverage_plugin

        require "#{ HERE_ }/plugins-/coverage/back"

        o = Plugins__::Coverage::Back.new @resources
        o.root_directory_path = @root_directory_path
        o.execute

      end

      def __build_dispatcher

        require "#{ HERE_ }/lib-"

        disp = Plugin_::Dispatcher.new @resources do | * i_a, & ev_p |

          first_two = i_a.shift 2  # `error`, `string`

          i_a.reverse!  # `authentication_failure`, `user` ..

          i_a.concat first_two  # `__receive__user_authentication_failure_error_string__`

          meth = :"__receive__#{ i_a * UNDERSCORE_ }__"

          if ! respond_to? meth
            meth = :"__receive__#{ first_two * UNDERSCORE_ }__"
          end

          send meth, & ev_p  # result is result
        end

        disp.state_machine(

          :started, :finish, :finished,

          :started, :build_sidesystem_tree, :produced_sidesystem_tree,

          :produced_sidesystem_tree, :flush_the_sidesystem_tree, :finished,

          :produced_sidesystem_tree, :reduce_the_sidesystem_tree, :produced_sidesystem_tree,

          :produced_sidesystem_tree, :build_the_test_files, :produced_the_test_files,

          :produced_the_test_files, :reduce_the_test_files, :produced_the_test_files,

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

      def __receive__for_plugin_dispatcher__
        @dsp
      end

      def __receive__for_plugin_program_name__
        _program_name
      end

      def __receive__for_plugin_root_directory_path__
        @root_directory_path
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

      def __receive__error_expression__ & y_p

        _expression_agent.calculate _serr_yielder, & y_p
        @was_unable = true
        nil
      end

      def __receive__error_event__ & ev_p

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
        _receive_error_event ev_p[]
      end

      # ~ support for above

      def _receive_error_event ev
        _render_into_stderr_event ev
        @was_unable = true
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

        ev.render_all_lines_into_under _serr_yielder, _expression_agent
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

    class Expression_Agent___  # #todo after :+#dev cull this

      alias_method :calculate, :instance_exec


      def and_ s_a
        Callback_::Oxford_and[ s_a ]
      end

      def ick msg
        "\"#{ msg }\""
      end
      def kb msg
        "`#{ msg }`"
      end
      def kbd msg
        ( @kbd ||= curry :green )[ msg ]
      end
      def hdr msg
        ( @hdr ||= _curry :green )[ msg ]
      end
      def multiline a
        1 == a.length ? " #{ a[0] }" : "\n#{ a * "\n" }"
      end

      def or_ s_a
        Callback_::Oxford_or[ s_a ]
      end

      def par x

        _nm = if x.respond_to?( :ascii_only? ) || x.respond_to?( :id2name )
          Callback_::Name.via_slug x
        else
          x.name
        end

        "<#{ _nm.as_slug }>"
      end

      def s * x_a
        Tree_Runner_::Lib_::NLP[]::EN::s( * x_a )
      end

      def val x
        x.inspect
      end

      # ~

      def indefinite_noun s
        _NLP_agent.indefinite_noun[ s ]
      end

      def progressive_verb s
        _with_split_and_join :progressive_verb, s
      end

      def third_person s
        _with_split_and_join :third_person, s
      end

      def _with_split_and_join meth, s
        s_a = s.split SPACE_
        s_a[ 0 ] = _NLP_agent.send( meth )[ s_a[ 0 ] ]
        s_a * SPACE_
      end

      def _curry x
        Tree_Runner_::Lib_::CLI_lib[].pen.stylify.curry[ [ * x ] ]
      end

      def _NLP_agent
        Tree_Runner_::Lib_::NLP[]::EN::POS
      end
    end

      HERE_ = ::File.expand_path '..', __FILE__

      Plugins__= ::Module.new

      SPACE_ = ' '.freeze

      Tree_Runner_ = self
    end
  end
end
