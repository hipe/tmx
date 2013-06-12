module Skylab::GitViz

  class CLI::Client

    extend Porcelain::Legacy::DSL

    include Core::Client_IM_

    desc 'ping'  # #todo - comment this out and it borks b/c not impl.

    def ping
      _dispatch
    end

    desc 'fun data viz reports on a git project.'

    argument_syntax '[<path>]'

    def hist_tree path=nil
      _dispatch path: path
    end

  dsl_off

    # would-be "services"

    attr_reader :y

    def last_hot_local_normal
      @legacy_last_hot._sheet._name.local_normal
    end

  private

    def initialize( * )
      super
      @y = ::Enumerator::Yielder.new( & @infostream.method( :puts ) )
      nil
    end

    # go FLAT here, this is all blood cleanup

    def _dispatch h=nil
      i = last_hot_local_normal
      k = CLI::Actions.const_get camelize( i ), false
      k.new( self ).invoke h
    end
  end
end

# (keep this line for posterity - there was some AMAZING foolishness going
# on circa early '12 that is a good use case for why autoloader #todo)
