module Skylab::TestSupport

  module Quickie

    class Sessions_::Front
      # <-
    module Eventpoint_Graph___

      Home_.lib_.task::Eventpoint::Graph[ self ]

      BEGINNING = eventpoint

      TEST_FILES = eventpoint do
        from BEGINNING
      end

      CULLED_TEST_FILES = eventpoint do
        from TEST_FILES
      end

      BEFORE_EXECUTION = eventpoint do
        from CULLED_TEST_FILES
      end

      EXECUTION = eventpoint do
        from BEFORE_EXECUTION
      end

      FINISHED = eventpoint do
        from BEGINNING
        from CULLED_TEST_FILES
        from EXECUTION
      end
    end
    # ->
      POSSIBLE_GRAPH = Eventpoint_Graph___.possible_graph

      def initialize dae

        dae.receive_mixed_client_ self

        @_daemon = dae
        @infostream = nil
        @paystream = nil
        @_plugins = nil
        @program_moniker = nil
        @x_a_a = nil
        @y = nil
      end

      def _svc
        @_daemon  # #hacks-only
      end

      attr_writer :do_recursive, :program_moniker

      def set_three_streams _, o, e
        @paystream = o ; @infostream = e
        @y = nil
      end

      def receive_argv__ argv

        @_do_execute = false

        ok = __load_plugins
        ok &&= __via_plugins_resolve_signatures argv
        ok &&= __check_if_ARGV_is_completely_parsed_via_sigs
        ok &&= __resolve_path_via_trueish_sigs
        ok &&= __emit_each_eventpoint_to_all_subscribed_plugins

        if @_do_execute
          bc = __bound_call_for_test_execution
          if bc
            bc.receiver.send bc.method_name, * bc.args, & bc.block
          else
            bc
          end
        else
          ok
        end
      end

      # -- services for dependencies

      # ~ test path, execution writers

      def yes_do_execute__
        @_do_execute = true
      end

      def replace_test_path_s_a path_s_a
        @_plugins[ :run_recursive ].dependency_.replace_test_path_s_a path_s_a
      end

      # ~ test-path readers

      def get_test_path_array  # #reach-down
        @_plugins[ :run_recursive ].dependency_.get_any_test_path_array
      end

      def to_test_path_stream
        @_plugins[ :run_recursive ].dependency_.to_test_path_stream
      end

      # ~ UI-related readers

      def program_moniker
        @program_moniker or ::File.basename $PROGRAM_NAME
      end

      def moniker_
        "#{ program_moniker } "
      end

      # ~ IO-related readers

      def y
        @y ||= ::Enumerator::Yielder.new( & infostream_.method( :puts ) )
      end

      def infostream_
        @infostream || @_daemon.infostream_
      end

      def paystream_
        @paystream || @_daemon.paystream_  # may be mounted under a supernode
      end

      # ~ misc

      def add_iambic x_a
        @x_a_a ||= []
        @x_a_a.push x_a ; nil
      end

      attr_reader :x_a_a

      # -- service API for performers

      def receive_test_context_class__ tcc  # from an outermost runtime
        # when the files start loading, this is the hookback
        @executor.receive_test_context_class___ tcc
      end

    private

      # -- UI

      def invite_string
        "see '#{ program_moniker } --help'"
      end

      def argument_error argv

        @y << "#{ moniker_ }aborting because none of the plugins or #{
          }loaded spec files processed the argument(s) - #{
          }#{ argv.map( & :inspect ) * SPACE_ }"

        @y << invite_string

        NIL_
      end

      def usage
        @_plugins[ :help ].dependency_.usage
        NIL_
      end

      # -- plugin mechanics

      def __load_plugins

        @_plugins and self._STATE_FAILURE

        o = Home_.lib_.plugin::BaselessCollection.new
        o.eventpoint_graph = POSSIBLE_GRAPH
        o.modality_const = :CLI
        o.plugin_services = self
        o.plugin_tree_seed = Here_::Plugins

        ok = o.load_all_plugins
        ok and begin @_plugins = o ; ACHIEVED_ end
      end

      def __via_plugins_resolve_signatures argv

        if '--help' == argv[0]  # while #open [#030]
          argv[0] = '-help'
        end

        frozen_argv = argv.dup.freeze

        a = []

        @_plugins.accept do | de |
          a.push de.prepare frozen_argv
        end

        if ! a.any?  # not a.lenght.zero?
          if frozen_argv.length.zero?
            @y << "nothing to do."
            @y << invite_string
            NIL_
          else
            argument_error argv
          end
        else
          @_sig_a = a ; KEEP_PARSING_
        end
      end

      def __check_if_ARGV_is_completely_parsed_via_sigs  # assume any

        scn = Common_::Scanner.via_array @_sig_a

        sig = Next_trueish__[ scn ]   # assume one

        xtra_a = ::Array.new sig.input.length, true

        begin

          sig.input.each_with_index do |x, idx|  # ( bitwise OR )
            if x.nil?
              xtra_a[ idx ] &&= nil
            elsif true == xtra_a[ idx ]
              xtra_a[ idx ] = x
            end
          end

          sig = Next_trueish__[ scn ]

          sig or break
          redo
        end while nil

        if xtra_a.any?
          argument_error xtra_a.compact
        else
          ( @_trueish_sig_a = remove_instance_variable( :@_sig_a ) ).compact!
          ACHIEVED_
        end
      end

      Next_trueish__ = -> scn do
        begin
          if scn.no_unparsed_exists
            break
          end
          x = scn.gets_one
          x and break
          redo
        end while nil
        x
      end

      def __resolve_path_via_trueish_sigs

        @_graph = POSSIBLE_GRAPH

        wv = @_graph.reconcile @y, :BEGINNING, :FINISHED, @_trueish_sig_a
        if wv
          @_path = wv.value_x
          ACHIEVED_
        else
          @y << "aborting because of the above. #{ invite_string }"
          NIL_
        end
      end

      def __emit_each_eventpoint_to_all_subscribed_plugins

        st = @_path.to_stream
        sym = :BEGINNING
        begin

          ok = ___emit_eventpoint_to_all_subscribed_plugins sym
          ok or break

          pred = st.gets
          if ! pred
            break
          end

          sym = pred.after_symbol

          redo
        end while nil
        ok
      end

      def ___emit_eventpoint_to_all_subscribed_plugins eventpoint_sym

        ep = @_graph.fetch_eventpoint eventpoint_sym

        ok = true

        @_plugins.accept do | de |

          sig = de.signature
          sig or next

          if ! sig.subscribed_to? ep
            next
          end

          x = de.eventpoint_notify ep
          if false == x
            ok = x
            break
          end
        end
        ok
      end

      def __bound_call_for_test_execution

        o = Here_::Sessions_::Execute.new(

          @y, get_test_path_array, @_daemon.program_name_string_array_

        ) do | q |

          if @x_a_a
            __set_quickie_options q
          end
        end

        o.be_verbose = @_plugins[ :run_recursive ].dependency_.be_verbose
        @executor = o
        o.produce_bound_call
      end

      def __set_quickie_options quickie
        @x_a_a.each do |x_a|
          quickie.with_iambic_phrase x_a
        end
        NIL_
      end
    end
  end
end
# #tombstone: `function_chain`
