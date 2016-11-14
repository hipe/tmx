
#                     ~ [#bn-005] explains it all ~

if ! defined? ::Skylab::BNF2Treetop

  # we won't know if the tmx specs run before our own do

  _sidesystem_path = ::File.expand_path '../../..', __FILE__

  load ::File.join( _sidesystem_path, 'bin/tmx-bnf2treetop' )
end
