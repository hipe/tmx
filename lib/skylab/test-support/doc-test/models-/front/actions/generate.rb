module Skylab::TestSupport

  module DocTest

    module Models_::Front

  class Actions::Generate < Action_  # storypoints are in [#015]

    # our handle on the whole doc-test API is the API module itself,
    # which you can call `call` on.
    #
    # probably no one will ever find a reason to call our API directly
    # to generate doc-test output. but for the purposes of testing and
    # in the interest of system design, we have made an API anyway.
    #
    # So, the `API` module is application programmer's interface to the API:
    #
    #     API = TestSupport_::DocTest::API
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
    #     here = DocTest_::Models_::Front::Actions::Generate.
    #       dir_pathname.sub_ext( '.rb' ).to_path
    #
    #     output_pn = TestSupport_.dir_pathname.
    #       join( 'test/doc-test/models-front-actions/generate/integration/core_spec.rb' )
    #
    #     stat = output_pn.stat ; size1 = stat.size ; ctime1 = stat.ctime
    #       # (this test assumes one such file already exists)
    #
    #     result = API.call :generate,
    #       :output_path, output_pn.to_path,
    #       :upstream_path, here,
    #       :force,
    #       :output_adapter, :quickie
    #
    #       # the moneyshot. did it work?
    #
    #     result  # => nil
    #       # for now this is nil on success
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

          o :is_promoted,

            :iambic_writer_method_name_suffix, :"="

          # NOTE those properties that want to trigger side-effects are
          # written by hand below, and for readability they write their
          # values directly to ivars. given this, we have to go ahead &
          # write all properties this way, otherwise we straddle values
          # being stored in two ways. maybe we'll automate it [#br-075]

          def business_module_name=
            @business_module_name = iambic_property
            KEEP_PARSING_
          end

          o :flag

          def dry_run=
            @dry_run = true
            KEEP_PARSING_
          end

          o :flag

          def force=
            @force = true
            KEEP_PARSING_
          end

          def line_downstream=
            x = iambic_property
            if x
              @line_downstream = x
              @do_close_downstream = false
              @resolve_line_downstream_method_name = :OK
            end
            KEEP_PARSING_
          end

          def line_upstream=
            x = iambic_property
            if x
              @line_upstream = x
              @resolve_line_upstream_method_name = :OK
            end
            KEEP_PARSING_
          end

          def template_variable_box=
            @template_variable_box = iambic_property
            KEEP_PARSING_
          end

          def output_adapter=
            @output_adapter = iambic_property
            KEEP_PARSING_
          end

          def output_path=
            x = iambic_property
            if x
              @output_path = x
              @resolve_line_downstream_method_name = :via_output_path_rslv_line_downstream
            end
            KEEP_PARSING_
          end

          def upstream_path=
            x = iambic_property
            if x
              @upstream_path = x
              @resolve_line_upstream_method_name =
                :via_upstream_path_rslv_line_upstream
            end
            KEEP_PARSING_
          end

        end

        def initialize kernel
          block_given? and self._WHAT
          @business_module_name = nil
          @dry_run = false
          @force = false
          @resolve_line_downstream_method_name = :when_no_downstream
          @resolve_line_upstream_method_name = :when_no_upstream
          @template_variable_box = nil
          @upstream_path = nil
          super
        end

        def produce_any_result

          # order is somewhat arbitrary: what is covered is to resolve
          # the output adapter first. normalization may hinge on a valid
          # upstream.

          ok = rslv_downstream
          ok &&= rslv_upstream
          ok &&= my_normalize
          ok && via_upstream_and_downstream_synthesize
          @result
        end

        # ~ resolve downstream

        def rslv_downstream
          ok = rslv_output_adatper
          ok && rslv_line_downstream
        end

        def rslv_output_adatper
          mod = Autoloader_.const_reduce [ @output_adapter ], DocTest_::Output_Adapters_ do |*i_a, & ev_p|
            @result = maybe_send_event_via_channel i_a, & ev_p
            UNABLE_
          end
          mod and begin
            @output_adapter_module = mod
            via_output_adapter_module_resolve_output_adapter
          end
        end

        def via_output_adapter_module_resolve_output_adapter
          @output_adapter = @output_adapter_module.output_adapter(
            @dry_run,
            & handle_event_selectively )
          ACHIEVED_
        end

        def rslv_line_downstream
          send @resolve_line_downstream_method_name
        end

        def when_no_downstream
          @result = maybe_send_event :error, :no_downstream do
            build_not_OK_event_with :no_downstream
          end
          UNABLE_
        end

        def via_output_path_rslv_line_downstream

          _force_arg = TestSupport_._lib.basic.trio(
            # because we use ivars and not property boxes, we must make this manually
            @force,
            true,
            self.class.property_via_symbol( :force ) )

          io = TestSupport_._lib.system.filesystem.normalization.downstream_IO(
            :path, @output_path,
            :is_dry_run, @dry_run,
            :force_arg, _force_arg,
            :on_event_selectively, handle_event_selectively )

          if io
            io.truncate 0
            @do_close_downstream = true
            @line_downstream = io
            ACHIEVED_
          else
            # upgrade any `nil` to `false` so that this spills all the way out
            @result = UNABLE_
            UNABLE_
          end
        end

        # ~ resolve upstream

        def rslv_upstream
          ok = rslv_line_upstream
          ok &&= rslv_comment_block_stream_via_line_stream
          ok && rslv_node_upstream_via_comment_block_stream
        end

        def rslv_line_upstream
          send @resolve_line_upstream_method_name
        end

        def when_no_upstream
          @result = maybe_send_event :error, :no_upstream do
            build_not_OK_event_with :no_line_upstream
          end
          UNABLE_
        end

        def via_upstream_path_rslv_line_upstream
          io = TestSupport_._lib.system.filesystem.normalization.upstream_IO(
            :path, @upstream_path,
            :on_event_selectively, -> * i_a, & ev_p do
              @result = maybe_send_event_via_channel i_a, & ev_p
              :error != i_a.first
            end )
          if io
            @line_upstream = io ; ACHIEVED_
          else
            UNABLE_
          end
        end

        def rslv_comment_block_stream_via_line_stream
          @comment_block_stream = DocTest_.
            comment_block_stream_via_line_stream_using_single_line_comment_hack(
              @line_upstream )
          @comment_block_stream ? ACHIEVED_ : UNABLE_
        end

        def rslv_node_upstream_via_comment_block_stream
          @node_upstream = @comment_block_stream.expand_by do | comment_block |
            DocTest_::Intermediate_Streams_::Node_stream_via_comment_block_stream[ comment_block ]
          end
          @node_upstream ? ACHIEVED_ : UNABLE_
        end

        # ~ normalize

        def my_normalize
          @business_module_name ||= DocTest_::Actors_::
            Infer_business_module_name_loadlessly.call(
               @upstream_path, & handle_event_selectively )
          if @business_module_name
            ACHIEVED_
          else
            @result = @business_module_name
            UNABLE_
          end
        end

        # ~ synthesize

        def via_upstream_and_downstream_synthesize

          @result = @output_adapter.against(
            :business_module_name, @business_module_name,
            :line_downstream, @line_downstream,
            :node_upstream, @node_upstream,
            :template_variable_box, @template_variable_box )

          if @do_close_downstream
            @line_downstream.close
          end

          nil
        end

        # ~ support

        def OK
          ACHIEVED_
        end
  end
    end
  end
end
