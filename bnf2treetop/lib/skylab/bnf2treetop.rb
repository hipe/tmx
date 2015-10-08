
#                     ~ [#bn-005] explains it all ~

if ! defined? ::Skylab::Bnf2Treetop

  # we won't know if the tmx specs run before our own do

  _sidesys_path = ::File.expand_path '../../..', __FILE__

  load ::File.join( _sidesys_path, 'bin/tmx-bnf2treetop' )
end
