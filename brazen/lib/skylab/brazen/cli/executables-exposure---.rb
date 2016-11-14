module Skylab::Brazen

  class CLI

    module Executables_Exposure___

#==FROM

    # (this new work is being spliced into this old file because it's
    # an exact replacement for the old node and one day etc.)

    class Skylab__Zerk__ArgumentScanner__OperatorBranch_via_Directory

      # exactly [#ze-051] the essay "the operator branch structure pattern"

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize
        @prefix = nil
        yield self
        freeze
      end

      # -- definition time

      def directory dir
        @directory = dir ; nil
      end

      def parent_module_of_executables mod

        # (for now we are optimistic that this will result in a read success)

        @__up_const_path = mod.name.split CONST_SEP_
        NIL
      end

      def mandatory_prefix_to_disregard s
        @prefix = s ; nil
      end

      def filesystem_function_implementors globber, fs, loader
        @filesystem = fs
        @globber = globber
        @loader = loader ; nil
      end

      # -- read time

      def [] k  # (interface will change when [#subject])

        name = Common_::Name.via_lowercase_with_underscores_symbol k

        path = ::File.join @directory, "#{ @prefix }#{ name.as_slug }"

        if @filesystem.file? path

          OneOff___.new path, name, @__up_const_path, @loader
        end
      end
    end

    # ==

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end
#==TO

      # [br] CLI is an adaptation of a reactive model to a particular
      # modality. this is an adaption of of scripts written "natively"
      # in that modality into .. the [br] CLI. yes, it's CLI for CLI.

      Action_stream_method = -> s do

        # result is the method body for a `to_unordered_selection_stream`
        # that exposes all the executable files in the usual location that
        # have the provided prefix, as if they were reactive action nodes.

        -> do

          _stream_1 = super()

          ss_mod = lookup_sidesystem_module

          glob = ::File.expand_path "../../../bin/#{ s }*",
            ss_mod.dir_path

          range = glob.length - 1 .. -1

          _s_a = ss_mod.name.split CONST_SEP_

          _stream_2 = Common_::Stream.via_nonsparse_array( ::Dir[ glob ] ) do | path |

            Executable_as_Unbound___.new( path[ range ], path, _s_a )
          end

          _stream_1.concat_stream _stream_2
        end
      end

      class Executable_as_Unbound___

        attr_reader(
          :name_function,
        )

        def initialize slug, path, const_ppfx

          @__const_pfx = const_ppfx
          @name_function = Common_::Name.via_slug slug
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

        def description_proc_for_summary_under _
          description_proc
        end

        def description_proc
          @___dp ||= ___build_description_proc
        end

        def ___build_description_proc

          bound = @_bound
          -> y do
            y << ::File.basename( bound.__path )
          end
        end

        # ~ needed to invoke

        def bound_call_under fr, & _oes_p  # [tmx]

          _one_off = __build_one_off

          o = fr.resources

          _one_off.to_bound_call_via_standard_five_resources(
            o.argv, o.sin, o.sout, o.serr, o.invocation_string_array )
        end

        def __build_one_off

          o = @_bound
          OneOff___.new o.__path, o.name_function, o.__const_pfx, ::Kernel
        end
      end
#==BEGIN KEEP

      class OneOff___

            # when it comes time to invoke the executable, it must follow a
            # few rules in order to be exposed by this [br]-integrated
            # modality face.

        def initialize path, name, up_const_path, loader

          st = Common_::Polymorphic_Stream.via_array up_const_path

          _head_const = st.gets_one

          buffer = ""
          begin
            buffer << "#{ st.gets_one }#{ UNDERSCORE_ }"
          end until st.no_unparsed_exists
          buffer << name.as_lowercase_with_underscores_string

            # the above is :[#083] the spot that realizes this name convention

          @_tail_const = buffer

          @__universe_module = ::Object.const_get _head_const, false

          @loader = loader
          @path = path
          @terminal_name = name
        end

        def to_bound_call_via_standard_five_resources argv, i, o, e, up_pn_s_a

          _proc_ish = __proc_like_loaded_if_necessary

          _pn_s_a = [ * up_pn_s_a, @terminal_name.as_slug ]

          _standard_five = [ argv, i, o, e, _pn_s_a ]

          Common_::Bound_Call[ _standard_five, _proc_ish, :call ]
        end

              # we cannot simply `require` it because it is not an ordinary
              # ruby library file. hypothetically we could `eval` it but
              # then it is harder to develop because no stack traces.

        def __proc_like_loaded_if_necessary

          # (the resource may have been loaded already if for example
          # you are using the test runner to test itself)

          univ_mod = @__universe_module
          const = @_tail_const

          if ! univ_mod.const_defined? const, false
            @loader.load @path
          end

          univ_mod.const_get const, false
        end

        attr_reader(
          :terminal_name,
        )
      end
#==END KEEP
    end
  end
end
