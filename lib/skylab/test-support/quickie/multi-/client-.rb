module Skylab::TestSupport

  module Quickie

    class Multi_::Client_

      Basic = TestSupport::Services::Basic

      def initialize svc
        @svc = svc
        @y = svc.y
      end

      def resolve argv
        a, b = find_contiguous_range_of_paths argv
        if ! a then
          @y << "expecting #{ usage_string }"
          nil
        else
          path_a = argv[ a, b ]
          argv[ a, b ] = MetaHell::EMPTY_A_
          (( path_a_ = reduce_files path_a )) and resolve_paths path_a_, argv
        end
      end

      attr_reader :y  # service

      def moniker_
        MONIKER_
      end
      MONIKER_ = 'recursive run '.freeze

      def attach_client_notify x
        @svc.attach_client_notify x
      end

      def argument_error argv
        @y << "#{ moniker_ }aborting because none of the loaded files #{
          }processed the argument(s) - #{ argv.map( & :inspect ) * ' ' }"
        false
      end

    private

      def find_contiguous_range_of_paths argv
        scn = Basic::List::Scanner[ argv ]
        while (( tok = scn.gets ))
          Dash_[ tok ] or break( a = scn.index )
        end
        if a
          b = 1
          while (( tok = scn.gets ))
            Dash_[ tok ] and break
            b += 1
          end
        end
        [ a, b ]
      end

      Dash_ = Headless::CLI::Option::FUN.starts_with_dash

      def usage_string
        "#{ client.program_name } [--list] <path> [..]"
      end

      def client
        @client ||= Quickie::Client.new @y, :no_context
      end

      def reduce_files path_a
        not_found = false ; lg = local_glob
        p = Basic::String::FUN.string_is_at_end_of_string_curry[ _spec_rb ]
        path_a_ = path_a.reduce [] do |m, path|
          if p[ path ]
            m << path
          elsif (( a = ::Dir[ "#{ path }/**/#{ lg }" ] )).length.zero?
            files_not_found path
            not_found = true
          else
            m.concat a.reverse  # ::Dir.glob is pre-order, we need post-order
          end
          m
        end
        not_found ? usage : path_a_
      end

      def _spec_rb
        TestSupport::FUN._spec_rb[]
      end

      def local_glob
        @local_glob ||= "*#{ _spec_rb }"
      end

      def usage
        @y << "usage: #{ usage_string }"
        nil
      end

      def files_not_found path
        @y << "#{ moniker_ }found no #{ @local_glob } files #{
          }under \"#{ path }\""
        nil
      end

      def resolve_paths path_a, argv
        if List_arg_[ argv ]
          if argv.length.nonzero?
            r = argument_error argv
          else
            path_a.each( & @svc.out.method( :puts ) )
          end
        else
          r = Quickie::Multi_::Run_.new( self, path_a ).resolve argv
        end
        r or maybe_invite r
      end

      List_arg_ = Headless::CLI::Option::FUN.basic_switch_scan_curry['--list']

      def maybe_invite r
        if false == r
          usage
          r = nil
        end
        r
      end
    end
  end
end
