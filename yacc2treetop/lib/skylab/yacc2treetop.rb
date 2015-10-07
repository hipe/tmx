
# read [#bn-005], this is a similar arrangement, tl;dr: for tmx integration

if ! defined? Skylab::Yacc2Treetop

  # when running all of the specs, we won't know if tmx ran before our own test

  _my_bin_dir = ::File.expand_path '../../../bin', __FILE__

  load ::File.join( _my_bin_dir, 'tmx-yacc2treetop' )

end
