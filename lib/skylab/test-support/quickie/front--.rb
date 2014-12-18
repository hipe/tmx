module Skylab::TestSupport

  module Quickie

    module Possibilities__

      Quickie::Possible_::Graph[ self ]

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

    POSSIBLE_GRAPH_ = Possibilities__.possible_graph  # protected-not-private

    class Front__

      def initialize svc
        @paystream = @infostream = @y = nil
        svc.attach_client_notify self
        @svc = svc
        @program_moniker = nil
      end

      def _svc
        @svc  # #hacks-only
      end

      attr_writer :do_recursive, :program_moniker
      alias_method :program_name=, :program_moniker=

      def set_three_streams _, o, e
        @paystream = o ; @infostream = e
        @y = nil
      end

      def invoke argv
        bc = QuicLib_::Function_chain[
          -> do
            ready_plugins
          end, -> do
            parse_argv argv
          end, -> sig_a do
            produce_bound_call_via_sig_a sig_a
          end ]
        bc and begin
          bc.receiver.send bc.method_name, * bc.args
        end
      end

      #  ~ services that plugins want ~

      def paystream
        @paystream || @svc.paystream  # may be mounted under a supernode
      end

      def y
        @y ||= ::Enumerator::Yielder.new( & infostream.method( :puts ) )
      end

      def infostream
        @infostream || @svc.infostream
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
        @plugins[ :run_recursive ].client.get_any_test_path_a
      end

      def replace_test_path_s_a path_s_a
        @plugins[ :run_recursive ].client.replace_test_path_s_a path_s_a
      end

      def add_context_class_and_resolve ctx
        # when the files start loading, this is the hookback
        @executor.add_context_class_and_resolve_notify ctx
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
          }#{ argv.map( & :inspect ) * ' ' }"
        @y << invite_string
        nil
      end

      def usage
        @plugins[ :help ].client.usage
        nil
      end

      #  ~ plugin mechanics ~

      def ready_plugins
        ( @plugins ||= Quickie::Plugin__::Box.new self, Quickie::Plugins ).
          ready
      end

      def parse_argv argv
        a = QuicLib_::Function_chain[
          -> { collect_signatures argv },
          -> sig_a { check_if_argv_is_completely_parsed sig_a } ]
        a and [ true, a ]
      end

      def collect_signatures argv
        argv_ = argv.dup.freeze
        a = @plugins._a.map { |pi| pi.prepare argv_ }
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
        scn = QuicLib_::Stream[ sig_a ] ; g = nil
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
          r, path = POSSIBLE_GRAPH_.reconcile_with_path_or_failure @y,
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
        e = Quickie::Execute__.new @y, get_test_path_a do |q|
          x_a_a and set_quickie_options q
        end
        e.be_verbose = @plugins[ :run_recursive ].client.be_verbose
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
        ep = POSSIBLE_GRAPH_.fetch_eventpoint eventpoint_i
        @plugins._a.each do |pi|
          (( sig = pi.signature )) or next
          if sig.subscribed_to? ep
            r = pi.eventpoint_notify ep
            false == r and break( ok = false )
          end
        end
        ok
      end
    end

    module QuicLib_

      Bsc__ = TestSupport_::Lib_::Basic

      CLI_lib = -> do
        HL__[]::CLI
      end

      EN_number = -> d do
        HL__[]::NLP::EN::Number.number d
      end

      Function_chain = -> * p_a do
        MH__[].function_chain[ p_a, nil ]
      end

      HL__ = TestSupport_::Lib_::HL__

      MH__ = TestSupport_::Lib_::MH__

      Name_const_basename = -> s do
        HL__[]::Name.const_basename s
      end

      Match_test_dir_proc = -> do
        TestSupport_.constant( :TEST_DIR_NAME_A ).method :include?
      end

      Oxford_and = Callback_::Oxford_and

      Oxford_or = Callback_::Oxford_or

      Pretty_path = -> x do
        HL__[].system.file_system.path_toosl.pretty_path x
      end

      Stream = Lib_::Stream

      String_lib = -> do
        Bsc__[]::String
      end

      SubTree__ = Autoloader_.build_require_sidesystem_proc :SubTree

      Tree = -> do
        SubTree__[]::Tree
      end
    end

    CEASE_ = false
    CONTINUE_ = nil
    SEP_ = '/'.freeze
  end
end
