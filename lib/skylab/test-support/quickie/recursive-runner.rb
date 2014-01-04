module Skylab::TestSupport

  module Quickie::Recursive_Runner

    ::Skylab::TMX::Front_Loader::One_shot_adapter_[ self,
      -> progname, i, o, e, argv do
        if '--ping' == argv[ 0 ]
          e.puts 'hello from quickie.'
          return :'hello_from_quickie'
        end
        run = ::Skylab::TestSupport::Quickie.active_session
        run.set_three_streams i, o, e
        run.program_name = progname
        run.do_recursive = true
        run.invoke argv
      end ]
  end
end
