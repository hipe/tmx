module Skylab::TestSupport

  module Quickie::Recursive_Runner

    ::Skylab::TMX::Front_Loader::One_shot_adapter_[ self,
      -> progname, i, o, e, argv do
        if '--ping' == argv[ 0 ]
          e.puts 'hello from quickie-recursive.'
          return :'hello_from_quickie-recursive'
        end
        run = ::Skylab::TestSupport::Quickie::service.run
        run.set_three_streams i, o, e
        run.program_name = progname
        run.do_recursive = true
        run.invoke argv
      end ]
  end
end
