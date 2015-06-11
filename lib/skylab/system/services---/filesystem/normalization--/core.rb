module Skylab::System


    class Services___::Filesystem

      class Normalization__

        # ~ begin experiment: agnostic prototype (could go up or down)

        Callback_::Actor.methodic self, :properties,

          :stdin, :stdout, :stderr,
          :dash_means

        def initialize & edit_p
          @do_recognize_common_string_patterns = false
          instance_exec( & edit_p )
        end

      private

        def recognize_common_string_patterns=
          @do_recognize_common_string_patterns = true
          KEEP_PARSING_
        end

        def result_in_IO_stream_identifier_trio=
          @do_result_in_IO_stream_identifier_trio = true
          KEEP_PARSING_
        end

      public

        def call * x_a, & x_p

          st = Callback_::Polymorphic_Stream.via_array x_a
          if :up_or_down != st.current_token
            raise ::ArgumentError, "required first term: `up_or_down`"
          end
          st.advance_one
          send :"__call_for__#{ st.gets_one }__", st, & x_p
        end

        def __call_for__up__ st, & x_p

          _call_this_guy N11n_::Upstream_IO__, st, & x_p
        end

        def __call_for__down__ st, & x_p

          _call_this_guy N11n_::Downstream_IO__, st, & x_p
        end

        def _call_this_guy cls, st, & x_p

          ivars = instance_variables
          me = self
          ok = false

          o = cls.new do  # :+#would-change-class

            ivars.each do | ivar |
              instance_variable_set ivar, me.instance_variable_get( ivar )
            end

            if x_p
              @on_event_selectively = x_p
            end

            ok = process_polymorphic_stream_fully st
          end
          ok && o.execute
        end

        # ~ end experiment

        class << self

          def downstream_IO * x_a, & oes_p

            if 1 == x_a.length
              x_a.unshift :path
            end

            Normalization__::Downstream_IO__.mixed_via_iambic_ x_a, & oes_p
          end

          def existent_directory * x_a, & oes_p
            Normalization__::Existent_Directory__.mixed_via_iambic_ x_a, & oes_p
          end

          def members
            singleton_class.instance_methods( false ) - [ :members ]
          end

          def upstream_IO * x_a, & oes_p

            if 1 == x_a.length
              x_a.unshift :path
            end

            Normalization__::Upstream_IO__.mixed_via_iambic_ x_a, & oes_p
          end

          def unlink_file * x_a, & oes_p
            Normalization__::Unlink_File__.mixed_via_iambic_ x_a, & oes_p
          end
        end  # >>

        module Common_Module_Methods_

          def mixed_with__ * x_a, & oes_p
            mixed_via_iambic_ x_a, & oes_p
          end

          def mixed_via_iambic_ x_a, & oes_p
            if x_a.length.nonzero?
              ok = nil
              x = new do
                accept_selective_listener_proc oes_p
                ok = process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
              end
              ok and x.produce_mixed_result_
            else
              self
            end
          end
        end

      private

        # ~ feature: this

        def via_path_arg_match_common_pattern_

          RX___.match @path_arg.value_x
        end

        RX___ = /\A (?:
          (?<integer>\d) (?=>\z) |
          (?<dash>-) \z
        ) /x

        def via_common_pattern_match_ md

          if md[ :dash ]
            __via_dash
          else
            d_s = md[ :integer ]
            if d_s
              via_system_resource_identifier_ d_s.to_i
            else
              self.via_matchdata_ md
            end
          end
        end

        def __via_dash
          send :"__via__#{ @dash_means }__"
        end

        def __via__stdin__
          via_stdin_
        end

        def via_stdin_
          _via_IO_stream @stdin
        end

        def __via__stdout__
          via_stdout_
        end

        def via_stdout_
          _via_IO_stream @stdout
        end

        def __via__stderr__
          via_stderr_
        end

        def via_stderr_
          _via_IO_stream @stderr
        end

        def _via_IO_stream x
          if x
            via_trueish_IO_stream_ x
          else
            raise ::ArgumentError
          end
        end

        def via_trueish_IO_stream_ x

          _my_x = byte_whichstream_identifier_.new x

          _my_result = @path_arg.new_with_value _my_x

          @as_normal_value[ _my_result ]
        end

        def when_invalid_system_resource_identifier_ d, * expecting

          same = :invalid_system_resource_identifier

          maybe_send_event :error, same do

            build_not_OK_event_with( same,

              :actual_value, d,
              :expecting_values, expecting,
              :which_stream, which_stream_

            ) do | y, o |

              _s_a = o.expecting_values.map( & method( :val ) )

              y << "system resource identifier for #{ o.which_stream } #{
                }cannot be #{ ick o.actual_value }, it must be #{
                  }#{ or_ _s_a }."
            end
          end
          UNABLE_
        end

        # ~ end feature

        def pathname_exists_and_set_stat_and_stat_error pn

          _set_stat_and_stat_error_by { pn.stat }
        end

        def path_exists_and_set_stat_and_stat_error path

          _set_stat_and_stat_error_by { ::File.stat path }
        end

        def _set_stat_and_stat_error_by  # :+[#021] (common maneuver)

          @stat_e = nil
          @stat = yield
          ACHIEVED_
        rescue ::Errno::ENOENT, Errno::ENOTDIR => @stat_e  # #todo assimilate the others
          @stat = nil
          UNABLE_
        end

        def build_wrong_ftype_event_ path, stat, expected_ftype_s

          build_not_OK_event_with :wrong_ftype,
              :actual_ftype, stat.ftype,
              :expected_ftype, expected_ftype_s,
              :path, path do |y, o|

            y << "#{ pth o.path } exists but is not #{
             }#{ indefinite_noun o.expected_ftype }, #{
              }it is #{ indefinite_noun o.actual_ftype }"
          end
        end

        Callback_::Event.selective_builder_sender_receiver self

        N11n_ = self
      end
    end
end
