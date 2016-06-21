module Skylab::DocTest

  module DocTest
    # ->
      class Models_::Generate < Action_  # storypoints are in [#001]

    # our handle on the whole doc-test API is the API module itself,
    # which you can call `call` on.
    #
    # probably no one will ever find a reason to call our API directly
    # to generate doc-test output. but for the purposes of testing and
    # in the interest of system design, we have made an API anyway.
    #
    # So, the `API` module is application programmer's interface to the API:
    #
    #     API = self._NO Lib_::DocTest::API
    #
    #
    # the minimal action that we can send to our API is the `ping` action:
    #
    #     API.call( :ping )  # => :_hello_from_doc_test_
    #
    #
    # we just pinged the API. if you had passed a selective event listener
    # as a final argument named `on_event_selectively`, you may have seen
    # additional output.
    #
    # Note how in this very comment block we have used "# =>" to indicate the
    # expected output from the line in our snippet. Note too that the snippet
    # is indented with four (4) spaces from the "normal" text.
    #
    # `ping` is one of several API actions (and the most boring, stable
    #  one at that). the action we are interested in using is the `generate`
    #  action.
    #
    #
    # let's write a comment that has a usage snippet showing how to generate
    # test code programmatically for this file you are reading,
    # from these comments you are reading:
    #
    #
    #     here = Home_::Models_::Front::Actions::Generate.
    #       dir_pathname.join( 'core.rb' ).to_path
    #
    #     output_pn = ::Pathname.new Top_TS_.test_path_(
    #       'doc-test/models-front-actions/generate/integration/core_spec.rb' )
    #
    #     stat = output_pn.stat
    #     size1 = stat.size
    #     ctime1 = stat.ctime
    #
    #       # (this test assumes one such file already exists)
    #
    #     em = API.call :generate,
    #       :output_path, output_pn.to_path,
    #       :upstream_path, here,
    #       :force,
    #       :output_adapter, :quickie
    #
    #       # the moneyshot. did it work?
    #
    #     em.category  # => [ :success, :wrote ]
    #       # (you could see number of lines, bytes written by calling
    #       #  the proc of the above emission.)
    #
    #     stat = output_pn.stat
    #
    #     stat.size  # => size1
    #       # the size should have stayed the same
    #     ( stat.ctime == ctime1 )  # => false
    #       # but the ctimes should be different
    #
    # (if that worked, that's just ridiculous. to see that this is working,
    # add e.g a blank like to the generated test file and re-run it again.
    # it should fail only the first time it is re-run.  #storypoint-15

        edit_entity_class do

          o(
            :inflect,
              :verb, 'generate',
              :noun, 'test document',
              :verb_as_noun, 'test document generation',

            :branch_description, -> y do
              y << "generate a test file from special"
              y << "comments in a code file."
            end,

            :enum, [ :intrinsic, :common_pfunc, :output_adapter_pfunc ],
            :default, :intrinsic,
            :meta_property, :origin_category,


            :polymorphic_writer_method_name_suffix, :"=",
          )

          # NOTE those properties that want to trigger side-effects are
          # written by hand below, and for readability they write their
          # values directly to ivars. given this, we have to go ahead &
          # write all properties this way, otherwise we straddle values
          # being stored in two ways. maybe we'll automate it [#br-075]

          o :description, -> y do
            y << "if this main `Foo::Bar::Baz` subject of your file is"
            y << "not specified here, a guess is attempted with a hack"
          end

          def business_module_name=
            @business_module_name = gets_one_polymorphic_value
            KEEP_PARSING_
          end

          o :flag

          def dry_run=
            @dry_run = true
            KEEP_PARSING_
          end

          o :flag, :description, -> y do
            y << "necessary to overwrite existing files"
          end

          def force=
            @force = true
            KEEP_PARSING_
          end

          def line_downstream=
            x = gets_one_polymorphic_value
            if x
              @do_emit_current_output_path = true
              @line_downstream = x
              @do_close_downstream = false
              @resolve_line_downstream_method_name = :OK
            end
            KEEP_PARSING_
          end

          def line_upstream=
            x = gets_one_polymorphic_value
            if x
              @line_upstream = x
              @resolve_line_upstream_method_name = :OK
            end
            KEEP_PARSING_
          end

          def arbitrary_proc_array=
            @_arbitrary_proc_a = gets_one_polymorphic_value
            KEEP_PARSING_
          end

          o :description, -> y do

            a = Home_.get_output_adapter_slug_array_

            a.map!( & method( :highlight ) )

            y << "available adapter#{ s a }: {#{ a * ' | ' }}. when used in"
            y << "conjunction with help, more options may appear."
          end

          def output_adapter=  # overwrites ("idempotence") must be OK

            # act on this immediately because it affects our syntax

            befor = @output_adapter
            x = gets_one_polymorphic_value
            if x
              x = x.intern
            end
            if befor == x
              KEEP_PARSING_
            else
              @output_adapter = x
              _resolve_output_adapter_instance
            end
          end

          o :description, -> y do
            y << "if this is not provided, the generated"
            y << "document will be written to STDOUT"
          end

          def output_path=
            x = gets_one_polymorphic_value
            if x
              @do_emit_current_output_path = false
                # (because an actor will emit a more specialized event)

              @output_path = x
              @resolve_line_downstream_method_name = :_resolve_line_downstream_via_output_path
            end
            KEEP_PARSING_
          end

          def upstream_path=
            x = gets_one_polymorphic_value
            if x
              @upstream_path = x
              @resolve_line_upstream_method_name =
                :via_upstream_path_rslv_line_upstream
            end
            KEEP_PARSING_
          end
        end

        def initialize boundish  # and oes_p

          @_arbitrary_proc_a = nil
          @arbitrary_O_A_proc_array = nil
          @business_module_name = nil
          @dry_run = false
          @do_emit_current_output_path = false
          @force = false
          @output_adapter = @output_adapter_o = nil
          @output_path = nil
          @resolve_line_downstream_method_name = :when_no_downstream_indicated_explicitly
          @resolve_line_upstream_method_name = :when_no_upstream
          @upstream_path = nil
          super
        end

        # ~ begin frontier experiment with curried actions

        def curry_action_with__ * x_a  # :+#frontier for [br]

          # experiment whereby we can "curry" an action "prototype" with
          # a set of default arguments. we can then dup this prototype &
          # run that dup against a specific request. this is intended to
          # reduce overhead for batch processing, where many items might
          # share the same base setup for execution. see the next method

          filesys_idioms  # build them now so you don't do so repeatedly

          _receive_dup_iambic x_a  # CAREFUL - same method that children use
        end

        def new_via_iambic x_a  # :+#frontier for [br]

          # this is the other side of the above method: call this method
          # on a prototype action and it will produce a new action whose
          # actual properties correspond to the iambic array provided on
          # top of the curried formal properties that were already there
          # but note that normalize isn't called yet. care must be taken
          # that the duped action will not have side-effects on this one

          dup._receive_dup_iambic x_a
        end

        def initialize_copy _
          if @output_adapter_o
            @output_adapter_o = @output_adapter_o.dup
          end
          nil
        end

        protected def _receive_dup_iambic x_a

          _st = Common_::Polymorphic_Stream.via_array x_a

          _ok = process_polymorphic_stream_fully _st

          _ok && self
        end

        def name_function  # for [#br-021] magic stream results (above)
          self.class.name_function
        end

        def execute  # no, this wasn't already implemented by the f.w!

          self._K

          @argument_box ||= Common_::Box.the_empty_box # ick/meh
          bc = via_arguments_produce_bound_call  # will call normalize
          bc and begin
            bc.receiver.send bc.method_name, * bc.args  # result matters
          end
        end

        # ~ end frontier experiment with curried actions

        # ~ begin experiment with dynamic syntax e.t al

        def receive_polymorphic_stream_ st

          # for collaboration with a modal client

          befor = [ @dry_run, @output_adapter ]  # ick
          ok = process_polymorphic_stream_fully st
          if ok
            aftr = [ @dry_run, @output_adapter ]
            if befor != aftr
              ok = _resolve_output_adapter_instance
            end
          end
          ok
        end

        def output_adapter_instance
          @output_adapter_o
        end

        def polymorphic_writer_method_name_passive_lookup_proc  # #hook-in [cb]

          formal_properties

          -> sym do

            if ! @__formal_properties__

              # then cache was cleared because output adapter changed

              formal_properties
            end

            prp = @__generate_action_formal_props_box__[ sym ]
            prp and __method_name_and_prepare_to_parse prp
          end
        end

        def formal_properties
          @__formal_properties__ ||= bld_dynamic_formal_properties
        end

      private

        def __method_name_and_prepare_to_parse prp
          case prp.origin_category
          when :intrinsic
            prp.polymorphic_writer_method_name
          when :common_pfunc
            @__parameter_function_property__ = prp
            :__parse_parameter_function_property
          when :output_adapter_pfunc
            @__O_A_param_func_prop__ = prp
            :__parse_output_adapter_pfunc
          end
        end

        Field_ = Home_.lib_.fields  # name is idiomatic

        def __parse_parameter_function_property

          prp = @__parameter_function_property__

          pfunc = Autoloader_.const_reduce(
            [ prp.name.as_const ],
            Parameter_Functions_ )

          oes_p = _event.handle_selectively

          if Field_::Takes_argument[ prp ]

            pfunc.call(
              self,
              polymorphic_upstream.gets_one,
              & oes_p )
          else

            pfunc.call self, & oes_p
          end
        end

        def __parse_output_adapter_pfunc

          @output_adapter_o.receive_stream_and_pfunc_prop(
            polymorphic_upstream,
            @__O_A_param_func_prop__ )
        end

        def bld_dynamic_formal_properties

          # for this action dynamic formal properties are always from
          # at least two sources (the class and the endemic parameter
          # functions.) as well, if an output adapter is selected, it
          # too adds parameter functions of its own to the dictionary
          # (which we use instead of a regular list so that each next
          # component in this chain may override the semantics of any
          # property provided by any previous component in the chain)

          bx = Cached_dictionary_starter___[]

          if @output_adapter_o
            bx = bx.dup
            @output_adapter_o.formal_properties_array.each do | prp |
              bx.add_or_replace prp.name_symbol, -> { prp }, -> _ { prp }
            end
          end

          @__generate_action_formal_props_box__ = bx

          _st = bx.to_value_stream

          _st.flush_to_immutable_with_random_access_keyed_to_method(
            :name_symbol )
        end

        Cached_dictionary_starter___ = Common_.memoize do

          bx = Common_::Box.new

          st = properties.to_value_stream

          prp = st.gets
          while prp

            if :upstream_path == prp.name_symbol  # hack for aesthetics, may change when [#br-078]
              break
            end

            bx.add prp.name_symbol, prp

            prp = st.gets
          end

          Parameter_Functions_.constants.each do | sym |

            _x = Parameter_Functions_.const_get sym, false

            prop = Parameter_Function_::Build_property_for_function.call(
              :common_pfunc,
              self::Property,
              _x,
              sym )

            bx.add_or_replace prop.name_symbol, -> do
              prop
            end, -> _ do
              prop
            end
          end

          while prp
            bx.add prp.name_symbol, prp
            prp = st.gets
          end

          bx.freeze
        end

        # ~ end experiment with dynamic syntax

        def produce_result

          self._K

          # order is somewhat arbitrary: what is covered is to resolve
          # the output adapter first. normalization may hinge on a valid
          # upstream.

          ok = ___resolve_downstream
          ok &&= __resolve_upstream
          ok &&= __normalize
          ok && __via_upstream_and_downstream_synthesize
        end

        # ~ resolve downstream

        def ___resolve_downstream

          ok = if @output_adapter_o
            ACHIEVED_
          else
            _resolve_output_adapter_instance  # even if no symbol, get the errmsg
          end

          if ok
            send @resolve_line_downstream_method_name
          else
            ok
          end
        end

        def _resolve_output_adapter_instance

          _ok = ___resolve_output_adapter_module
          _ok && via_output_adapter_module_resolve_output_adapter
        end

        def ___resolve_output_adapter_module

          mod = Autoloader_.const_reduce(
            [ @output_adapter ],  # nil ok
            Home_::OutputAdapters_,
            & @on_event_selectively )

          if mod
            @output_adapter_module = mod
            ACHIEVED_
          else
            mod
          end
        end

        def via_output_adapter_module_resolve_output_adapter
          @output_adapter_o = @output_adapter_module.output_adapter(
            @dry_run,
            & _event.handle_selectively )
          @__formal_properties__ = nil  # above may add some
          ACHIEVED_
        end

        def when_no_downstream_indicated_explicitly

          output_path

          if @output_path
            _resolve_line_downstream_via_output_path
          else

            @on_event_selectively.call :error, :no_downstream do
              _event.build_not_OK_with :no_downstream  # #could-go
            end

            UNABLE_
          end
        end

        def _resolve_line_downstream_via_output_path

          _force_arg = Common_::Qualified_Knownness.via_value_and_association(
            # because we use ivars and not property boxes, we must make this manually
            @force,
            self.class.properties.fetch( :force ) )

          kn = Home_.lib_.system.filesystem( :Downstream_IO ).with(
            :path, @output_path,
            :is_dry_run, @dry_run,
            :force_arg, _force_arg,
            & _event.handle_selectively )

          if kn
            io = kn.value_x
            io.truncate 0
            @do_close_downstream = true
            @line_downstream = io
            ACHIEVED_
          else
            # upgrade any `nil` to `false` so that this spills all the way out
            UNABLE_
          end
        end

        # ~ resolve upstream

        def __resolve_upstream
          ok = rslv_line_upstream
          ok &&= rslv_comment_block_stream_via_line_stream
          ok && rslv_node_upstream_via_comment_block_stream
        end

        def rslv_line_upstream
          send @resolve_line_upstream_method_name
        end

        def when_no_upstream

          @on_event_selectively.call :error, :no_upstream do

            _event.build_not_OK_with :no_line_upstream  # #could-go
          end

          UNABLE_
        end

        def via_upstream_path_rslv_line_upstream

          io = Home_.lib_.system.filesystem( :Upstream_IO ).against_path(

            @upstream_path,

          ) do | * i_a, & ev_p |

            @on_event_selectively.call( * i_a, & ev_p )
            TEMPORARY_
          end

          if io
            @line_upstream = io
            ACHIEVED_
          else
            io
          end
        end

        def rslv_comment_block_stream_via_line_stream
          @comment_block_stream = Home_.
            comment_block_stream_via_line_stream_using_single_line_comment_hack(
              @line_upstream )
          @comment_block_stream ? ACHIEVED_ : UNABLE_
        end

        def rslv_node_upstream_via_comment_block_stream

          st = @comment_block_stream.expand_by do | cb |
            Home_::Magnetics_::NodeStream_via_CommentBlock[ cb ]
          end

          if st
            @node_upstream = st ; ACHIEVED_
          else
            st
          end
        end

        # ~ normalize

        def __normalize

          @business_module_name ||= ___build_business_name

          if @business_module_name
            if @_arbitrary_proc_a
              when_arbitrary_procs
            else
              ACHIEVED_
            end
          else
            self._FIXX
            @result = @business_module_name
            UNABLE_
          end
        end

        def ___build_business_name

          _ = Home_::Magnetics_::Hack_Peek_Module_Name_via_Path.call(
            @upstream_path, & _event.handle_selectively )
          _
        end

        def when_arbitrary_procs
          ok = true
          @_arbitrary_proc_a.each do |p|
            ok = p[ self ]
            ok or break
          end
          ok
        end

      public  # ~ the public API for parameter functions (alphabetical by stem)

        # ~~ filesys idioms

        def filesys_idioms
          @FS_idioms ||= Home_::Models_::Filesystem.new
        end

        # ~~ output adapter

        def during_output_adapter & p
          ( @arbitrary_O_A_proc_array ||= [] ).push p
          ACHIEVED_
        end

        # ~~ output path

        def output_path

          if @output_path.nil? && @upstream_path

            x = Home_::Magnetics::OutputPath_via_InputPath[
              @upstream_path, _event.handle_selectively ]

            if x
              @output_path = x
            end
          end
          @output_path
        end

        def receive_output_path x
          if x
            @output_path = x
            ACHIEVED_
          else
            x
          end
        end

        # ~ synthesize

        def __via_upstream_and_downstream_synthesize

          if @do_emit_current_output_path
            ___emit_current_output_path
          end

          x = @output_adapter_o.against(
            :arbitrary_proc_array, @arbitrary_O_A_proc_array,
            :business_module_name, @business_module_name,
            :line_downstream, @line_downstream,
            :node_upstream, @node_upstream,
          )

          if @do_close_downstream
            @line_downstream.close
          end

          x
        end

        def ___emit_current_output_path

          _event.maybe_send :info, :current_output_path do

            Common_::Event.inline_neutral_with(
              :current_output_path,
              :path, @output_path,
            )
          end
          NIL_
        end

        # ~ support

        def OK
          ACHIEVED_
        end

        module Parameter_Functions_
          Common_::Autoloader[ self, :boxxy ]
        end

        Self_ = self
        TEMPORARY_ = false  # until a perfect work
      end
    # -
  end
end
