require_relative 'test-support'

Skylab::TestSupport::Quickie.enable_kernel_describe

describe "[hl] CLI path-tools pretty-path" do

  extend Skylab::Headless::TestSupport::System::Services::Filesystem::Path_Tools::Pretty_Path

  frame do
    home '/home/rms'
    exemplifying "contracts home directories to '~' (home is #{home.inspect})" do
      o '/home/rms/foo', '~/foo'
      o '/home/rms/foo/bar.txt', '~/foo/bar.txt'
      o 'home/rms/whatever', 'home/rms/whatever'
      o '/home/rms', '~'
      o '/home/rms/', '~/'
      o 'something/home/rms', 'something/home/rms'
    end
  end

  frame do
    pwd '/usr/local'
    exemplifying "contracts present working directory to '.' (pwd is #{pwd.inspect})" do
      o '/usr/local/foo', './foo'
      o '/usr/local/foo/bar.txt', './foo/bar.txt'
      o 'usr/local/whatever', 'usr/local/whatever'
      o '/usr/local', '.'
      o '/usr/local/', './'
      o 'something/usr/local', 'something/usr/local'
    end
  end

  frame do
    home '/home/rms'
    pwd home
    exemplifying "and if pwd *is* home dir, home dir always wins" do
      o '/home/rms', '~'
      o '/home/rms/foo', '~/foo'
    end
  end

  frame do
    home '/a/b/c'
    pwd  '/a/b'
    exemplifying "and if home dir (#{home}) is inside pwd (#{pwd}), home dir wins (shortest wins)" do
      o '/a/b/c/foo/bar', '~/foo/bar'
      o '/a/b/c/foo',     '~/foo'
      o '/a/b/c/',        '~/'
      o '/a/b/c',         '~'
      o '/a/b/',          './'
      o '/a/b',           '.'
      o '/a/',            '/a/'
      o 'a/b/c',          'a/b/c'
    end
  end

  frame do
    home '/home/rms'
    pwd  '/home/rms/proj'
    exemplifying "BUT if pwd (#{pwd}) is inside home (#{home}), PWD wins (shortest wins)" do
      o '/home/rms/proj/emacs.c', './emacs.c'
      o '/home/rms/proj',         '.'
      o '/home/rms/pro',          '~/pro'
      o '/home/rms',              '~'
      o 'home/rms',               'home/rms'
    end
  end

  frame do
    home '/home/rms'
    pwd '/home/rms/proj/emacs'
    exemplifying "pwd (#{ pwd }) is in home (#{ home }), relpath wins" do
      o '/home/rms/proj/hurd',   '../hurd'
    end
  end
end
