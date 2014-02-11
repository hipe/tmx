module Skylab::TestSupport

  module Quickie

    module Possibilities__

      Quickie::Possible_::Graph[ self ]

      BEGINNING = eventpoint

      TEST_FILES = eventpoint do
        from BEGINNING
      end

      BEFORE_EXECUTION = eventpoint do
        from TEST_FILES
      end

      EXECUTION = eventpoint do
        from BEFORE_EXECUTION
      end

      FINISHED = eventpoint do
        from BEGINNING
        from TEST_FILES
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
        @paystream, @infostream = o, e
        @y = nil
      end

      def invoke argv
        bm = Chain__[
          -> { ready_plugins },
          -> { parse_argv argv },
          -> sig_a { resolve sig_a } ]

        bm and bm.receiver.send bm.name
      end

      #  ~ services that plugins want ~

      def paystream
        @paystream || @svc.paystream  # may be mounted under a supernode
      end

      def infostream
        @infostream || @svc.infostream
      end

      def y
        @y ||= ::Enumerator::Yielder.new( & @infostream.method( :puts ) )
      end

      def program_moniker
        @program_moniker or ::File.basename $PROGRAM_NAME
      end

      def get_test_path_a  # #reach-down
        @plugins[ :run_recursive ].client.get_any_test_path_a
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
        a = Chain__[
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
        scn = QuicLib_::Scanner[ sig_a ] ; g = nil
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

      def resolve sig_a
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
              break(( r = resolve_executor ))  # hack for short stacks
          end
        end while nil
        if false == r
          @y << "aborting because of the above. #{ invite_string }"
          r = nil
        end
        r
      end

      def resolve_executor
        e = Quickie::Execute__.new @y, get_test_path_a
        e.be_verbose = @plugins[ :run_recursive ].client.be_verbose
        (( @executor = e )).resolve
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

      CLI_basic_switch_index = -> sw do
        Headless__[]::CLI::Option::FUN.basic_switch_index_curry[ sw ]
      end

      CLI_starts_with_dash = -> s do
        Headless__[]::CLI::Option::FUN.starts_with_dash[ s ]
      end

      EN_number = -> d do
        Headless__[]::NLP::EN::Number::FUN.number[ d ]
      end

      Headless__ = TestSupport_::Lib_::Headless__

      Name_const_basename = -> s do
        Headless__[]::Name::FUN::Const_basename[ s ]
      end

      Match_test_dir_proc = -> do
        require 'skylab/sub-tree/constants'  # special case, avoid loading core
        ::Skylab::SubTree::Constants::TEST_DIR_NAME_A.method :include?
      end

      Oxford_and = Callback_::Oxford_and

      Oxford_or = Callback_::Oxford_or

      Pretty_path = -> x do
        Headless__[]::CLI::PathTools::FUN::Pretty_path[ x ]
      end
    end

    Chain__ = MetaHell::FUN.function_chain

  end
end
