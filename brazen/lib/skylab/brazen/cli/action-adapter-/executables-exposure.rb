module Skylab::Brazen

  class CLI

    module Action_Adapter_::Executables_Exposure

      # [br] CLI is an adaptation of a reactive model to a particular
      # modality. this is an adaption of of scripts written "natively"
      # in that modality into .. the [br] CLI. yes, it's CLI for CLI.

      Action_stream_method = -> s do

        # result is the method body for a `to_child_unbound_action_stream`
        # that exposes all the executable files in the usual location that
        # have the provided prefix, as if they were reactive action nodes.

        -> do

          _stream_1 = super()

          ss_mod = lookup_sidesystem_module

          glob = ::File.expand_path "../../../bin/#{ s }*",
            ss_mod.dir_pathname.to_path

          range = glob.length - 1 .. -1

          _s_a = ss_mod.name.split CONST_SEP_

          _stream_2 = Callback_::Stream.via_nonsparse_array( ::Dir[ glob ] ) do | path |

            Executable_as_Unbound___.new( path[ range ], path, _s_a )
          end

          _stream_1.concat_by _stream_2
        end
      end

      class Executable_as_Unbound___

        attr_reader(
          :name_function,
        )

        def initialize slug, path, const_ppfx

          @__const_pfx = const_ppfx
          @name_function = Callback_::Name.via_slug slug
          @__path = path
        end

        def adapter_class_for _
          self
        end

        def new _this, k, & oes_p

          Executable_as_Bound___.new k, self, & oes_p
        end

        attr_reader(
          :__const_pfx,
          :__path,
        )
      end

      class Executable_as_Bound___

        def initialize k, bound, & oes_p

          @_bound = bound
        end

        # ~ needed by index

        def is_visible
          true
        end

        def name_value_for_order
          @_bound.name_function.as_lowercase_with_underscores_symbol
        end

        def name
          @_bound.name_function
        end

        def after_name_value_for_order
          NIL_
        end

        # ~ needed to reflect

        def has_description
          true
        end

        def under_expression_agent_get_N_desc_lines expag, n=nil
          [ ::File.basename( @_bound.__path ) ]
        end

        # ~ needed to invoke

        def bound_call_via_receive_frame fr, & oes_p

          Callback_::Bound_Call.by do

            # when it comes time to invoke the executable, it must follow a
            # few rules in order to be exposed by this [br]-integrated
            # modality face.

            const_pfx = @_bound.__const_pfx
            name = @_bound.name_function

            top_const = const_pfx.fetch 0

            sub_const = "#{ const_pfx[ 1 .. -1 ].join( UNDERSCORE_ ) }#{
              }_#{ name.as_lowercase_with_underscores_symbol }"

            # there is at least one case where the executable has been loaded
            # already: if you are using the test runner to test itself

            if ! ( ::Object.const_defined? top_const, false and

                ::Object.const_get( top_const ).const_defined? sub_const, false )

              load @_bound.__path

              # we cannot simply `require` it because it is not an ordinary
              # ruby library file. hypothetically we could `eval` it but
              # then it is harder to develop because no stack traces.

            end

            o = fr.resources

            a = o.invocation_string_array.dup
            a.push name.as_slug

            _top_module = ::Object.const_get top_const, false
            _func = _top_module.const_get sub_const, false
            _func[ o.sin, o.sout, o.serr, a, o.argv ]
          end
        end
      end
    end
  end
end
