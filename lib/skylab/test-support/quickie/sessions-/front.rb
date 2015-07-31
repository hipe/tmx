module Skylab::TestSupport

  module Quickie

    class Sessions_::Front

      # <-

    module Possibilities___

      Here_::Possible_::Graph[ self ]

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

      POSSIBLE_GRAPH = Possibilities___.possible_graph

      def initialize dae

        dae.receive_mixed_client_ self

        @_daemon = dae
        @infostream = nil
        @paystream = nil
        @plugins = nil
        @program_moniker = nil
        @x_a_a = nil
        @y = nil
      end

      def _svc
        @_daemon  # #hacks-only
      end

      attr_writer :do_recursive, :program_moniker
      alias_method :program_name=, :program_moniker=

      def set_three_streams _, o, e
        @paystream = o ; @infostream = e
        @y = nil
      end

      def invoke argv

        _p = Home_.lib_.function_chain(

          -> do
            load_plugins
          end,

          -> do
            parse_argv argv
          end,

          -> sig_a do

            produce_bound_call_via_sig_a sig_a
          end,
        )

        bc = _p[]
        if bc
          bc.receiver.send bc.method_name, * bc.args
        end
      end

      #  ~ services that plugins want ~

      def paystream_
        @paystream || @_daemon.paystream_  # may be mounted under a supernode
      end

      def y
        @y ||= ::Enumerator::Yielder.new( & infostream_.method( :puts ) )
      end

      def infostream_
        @infostream || @_daemon.infostream_
      end

      def program_moniker
        @program_moniker or ::File.basename $PROGRAM_NAME
      end

      def add_iambic x_a
        @x_a_a ||= []
        @x_a_a.push x_a ; nil
      end

      attr_reader :x_a_a

      def get_test_path_a  # #reach-down
        @plugins[ :run_recursive ].dependency_.get_any_test_path_a
      end

      def to_test_path_stream
        @plugins[ :run_recursive ].dependency_.to_test_path_stream
      end

      def replace_test_path_s_a path_s_a
        @plugins[ :run_recursive ].dependency_.replace_test_path_s_a path_s_a
      end

      def receive_context_class__ ctx
        # when the files start loading, this is the hookback
        @executor.receive_context_class___ ctx
      end

      def moniker_
        "#{ program_moniker } "
      end

    private

      # ~ UI

      def invite_string
        "see '#{ program_moniker } --help'"
      end

      def argument_error argv
        @y << "#{ moniker_ }aborting because none of the plugins or #{
          }loaded spec files processed the argument(s) - #{
          }#{ argv.map( & :inspect ) * SPACE_ }"
        @y << invite_string
        nil
      end

      def usage
        @plugins[ :help ].dependency_.usage
        nil
      end

      #  ~ plugin mechanics ~

      def load_plugins

        if @plugins
          self._STATE_FAILURE
        else
          col = __build_plugins_collection
          if col
            @plugins = col
            ACHIEVED_
          else
            UNABLE_
          end
        end
      end

      def __build_plugins_collection

        if Here_.const_defined? :Plugins, false

          mod = Here_.const_get :Plugins

        else

          mod = ::Module.new
          Here_.const_set :Plugins, mod  # :+#stowaway
          Autoloader_[ mod, :boxxy ]
        end

        col = Here_::Plugin_::Collection.new self, mod

        ok = col.initialize_all__

        if ok
          col
        else
          ok
        end
      end

      def parse_argv argv

        _p = Home_.lib_.function_chain(

          -> { collect_signatures argv },

          -> sig_a { check_if_argv_is_completely_parsed sig_a },
        )

        _array_of_one_element = _p[]

        if _array_of_one_element
          [ true, _array_of_one_element ]
        end
      end

      def collect_signatures argv
        argv_ = argv.dup.freeze
        a = @plugins.a_.map { |pi| pi.prepare argv_ }
        if a.any?
          [ true, a ]
        elsif argv.any?
          argument_error argv
        else
          @y << "nothing to do."
          @y << invite_string
          nil
        end
      end

      def check_if_argv_is_completely_parsed sig_a  # assume any

        g = nil
        scn = Callback_::Scn.try_convert sig_a
        until (( g = scn.gets )) ; end
        xtra_a = ::Array.new g.input.length, true
        begin  # ( bitwise OR )
          g.input.each_with_index do |x, idx|
            if x.nil?
              xtra_a[ idx ] &&= nil
            elsif true == xtra_a[ idx ]
              xtra_a[ idx ] = x
            end
          end
          g = nil
          until (( scn.eos? or g = scn.gets )) ; end
          g or break
        end while true
        if xtra_a.any?
          argument_error xtra_a.compact
        else
          sig_a.compact!
          [ true, sig_a ]
        end
      end

      def produce_bound_call_via_sig_a sig_a
        begin
          r, path = POSSIBLE_GRAPH.reconcile_with_path_or_failure @y,
            :BEGINNING, :FINISHED, sig_a
          r or break
          path_a = path.get_a
          current_eventpoint = :BEGINNING
          while true
            emit_eventpoint( current_eventpoint ) or break(( r = false ))
            (( from_pred = path_a.shift )) or break
            :EXECUTION == (( current_eventpoint = from_pred.to_i )) and
              break(( r = via_executor_produce_bound_call ))  # hack for short stacks
          end
        end while nil
        if false == r
          @y << "aborting because of the above. #{ invite_string }"
          r = nil
        end
        r
      end

      def via_executor_produce_bound_call

        e = Here_::Sessions_::Execute.new(

          @y, get_test_path_a, @_daemon.program_name_string_array_

        ) do | q |

          if @x_a_a
            set_quickie_options q
          end
        end

        e.be_verbose = @plugins[ :run_recursive ].dependency_.be_verbose
        @executor = e
        e.produce_bound_call
      end

      def set_quickie_options quickie
        @x_a_a.each do |x_a|
          quickie.with_iambic_phrase x_a
        end ; nil
      end

      def emit_eventpoint eventpoint_i
        ok = true
        ep = POSSIBLE_GRAPH.fetch_eventpoint eventpoint_i
        @plugins.a_.each do |pi|
          (( sig = pi.signature )) or next
          if sig.subscribed_to? ep
            r = pi.eventpoint_notify ep
            false == r and break( ok = false )
          end
        end
        ok
      end
    end
  end
end
