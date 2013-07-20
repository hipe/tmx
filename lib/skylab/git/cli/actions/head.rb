module Skylab::Git

  CLI::Actions::Head = -> cli, argv do
    cli.instance_exec do
      _SELF = 'head' ; ready = true ; y = get_y ; is_dry_run = nil
      progname = -> { progname_for _SELF }
      usage_string = -> { "#{ progname[] } [opts] <file>" }
      op = Git::Services::OptionParser.new do |o|
        help = -> _ do
          ready = false
          y << "#{ hi 'usage:' } #{ usage_string[] }\n\n"
          y << "#{ hi 'description:' } moves your file to a temporary"
          y << "location, checks out a copy from HEAD of the file, moves *it*"
          y << "to \"foo.HEAD.rb\", and moves your file back in place.\n\n"
          y << "#{ hi 'option:' }"

          op.summarize( & y.method( :<< ) )
        end
        o.on '-h', '--help', & help
        o.on '-n', '--dry-run' do is_dry_run = true end
      end
      invite = -> msg=nil do
        ready = false
        y << msg if msg
        y << "see #{ hi "#{ progname[] } -h" }"
      end
      begin
        op.permute! argv
      rescue ::OptionParser::ParseError => e
        invite[ e.message ]
      end
      if ready && 1 != argv.length
        y << "unexpected number of arguments - #{ argv.length }"
        y << "usage: #{ usage_string[ ] }"
        invite[]
      end
      if ready
        Git::API::Actions::
          Head[ :y, y, :path, argv.fetch( 0 ), :is_dry_run, is_dry_run ]
      end
    end
  end
end
