require_relative 'test-support'

module Skylab::Treemap::TestSupport::CLI

  describe "[tr] CLI adapters", wip: true do  # quickie: no

    extend TS_

    num_streams 3

    it "`tm -h doobie` - single lone action with a normal screen" do
      client.invoke ['-h', 'doobie']
      styld 'usage: nerkiss doobie [-h] <arg1> <arg2> [<arg3>]'
      white
      styld( /description: do some doobies/ )
    end

    it "`tm -h install` - branch screen b.c more than one adapter" do
      client.invoke ['-h', 'install']
      styld 'usage: nerkiss install -a <NAME> [-h] [<adapter-specific-arg> [..]]'
      white
      styld( /there exist `install` actions for the foo-bar and r plugins\./i )
      white
      styld 'options:'
      styled( serrs.shift ).should be_include( 'adapter to use for install' )
      white
      styld 'try nerkiss install -h -a <NAME> for `install` help for that particular plugin.'
      serrs.length.should eql( 0 )
    end
  end
end
