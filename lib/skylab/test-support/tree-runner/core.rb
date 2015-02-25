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
        ok and begin
          @dsp = __build_dispatcher
          ok = @dsp.process_input_against_plugins_in_module @argv, Plugins__
          ok or __when_not_OK ok
        end
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

          send :"__receive__#{ i_a * UNDERSCORE_ }__", & ev_p  # result is result
        end

        disp.state_machine(

          :started, :finish, :finished,

          :started, :build_sidesystem_tree, :produced_sidesystem_tree,

          :produced_sidesystem_tree, :flush_the_sidesystem_tree, :finished,

          :produced_sidesystem_tree, :reduce_the_sidesystem_tree, :produced_sidesystem_tree,

          :produced_sidesystem_tree, :build_the_test_files, :produced_the_test_files,

          :produced_the_test_files, :reduce_the_test_files, :produced_the_test_files,

          :produced_the_test_files, :flush_the_test_files, :finished )

        disp
      end

      def __receive__dispatcher_request_by_plugin__
        @dsp
      end

      def __receive__help_event__ & ev_p

        ev_p[].render_all_lines_into_under @resources.serr, expression_agent_

        nil
      end

      def __receive__optparse_parse_error_exception__ & ev_p
        @resources.serr.puts ev_p[].message
        @was_unable = true
        UNABLE_
      end

      def __receive__unused_actuals_error_event__ & ev_p
        __write_event_to_stderr ev_p[]
        @was_unable = true
        UNABLE_
      end

      def __write_event_to_stderr ev
        ev.render_each_line_under expression_agent_ do | line |
          @resources.serr.puts line
        end
        nil
      end

      def __when_not_OK x
        if @was_unable
          __invite
        end
        x
      end

      def __invite  # watch for unification opportunities with [#ba-038]
        @resources.serr.puts "try `#{ __invocation_name } --help` for help"
        nil
      end

      def __invocation_name
        ::File.basename $PROGRAM_NAME
      end

      def expression_agent_
        @__expag__ ||= Expression_Agent___.new
      end


    class Expression_Agent___  # #todo after :+#dev cull this
      alias_method :calculate, :instance_exec
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

      def or_ a
        Tree_Runner_::Lib_::Oxford_and[ a ]
      end

      def par i
        "<#{ i.to_s.gsub '_', '-' }>"
      end

      # ~

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
