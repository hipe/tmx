
#                     ~ [#bn-005] explains it all ~

if ! defined? ::Skylab::Bnf2Treetop

  # we won't know if the tmx specs run before our own do

  load ::File.expand_path( '../../../../bin/tmx-bnf2treetop', __FILE__ )
end
