
desc "hax extreme, part of the #autobleed vaporware experiment"

task :'build-most-recent-rubinius' do
  exec "#{ ::File.dirname __FILE__ }/back-front"
end
