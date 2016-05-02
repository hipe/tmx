require_relative '../../test-support'

Skylab::TestSupport::Quickie.enable_kernel_describe

describe "[sy] - filesystem - pather - synopsis" do

  Skylab::System::TestSupport[ self ]
  use :filesystem_pather

  context do
    home '/home/rms'
    exemplifying "contracts home directories to '~'" do
      o '/home/rms/foo', '~/foo'
      o '/home/rms/foo/bar.txt', '~/foo/bar.txt'
      o 'home/rms/whatever', 'home/rms/whatever'
      o '/home/rms', '~'
      o '/home/rms/', '~/'
      o 'something/home/rms', 'something/home/rms'
    end
  end

  context do
    pwd '/usr/local'
    exemplifying "contracts present working directory to '.'" do
      o '/usr/local/foo', './foo'
      o '/usr/local/foo/bar.txt', './foo/bar.txt'
      o 'usr/local/whatever', 'usr/local/whatever'
      o '/usr/local', '.'
      o '/usr/local/', './'
      o 'something/usr/local', 'something/usr/local'
    end
  end

  context do
    same = '/home/rms'
    home same
    pwd same
    exemplifying "when home and pwd are the same, home wins" do
      o '/home/rms', '~'
      o '/home/rms/foo', '~/foo'
    end
  end

  context do
    home '/a/b/c'
    pwd  '/a/b'
    exemplifying "when home is under pwd, whatever would be shortest wins" do
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

  context do
    home '/home/rms'
    pwd  '/home/rms/proj'
    exemplifying "BUT if pwd is inside home, PWD wins (shortest wins)" do
      o '/home/rms/proj/emacs.c', './emacs.c'
      o '/home/rms/proj',         '.'
      o '/home/rms/pro',          '~/pro'
      o '/home/rms',              '~'
      o 'home/rms',               'home/rms'
    end
  end

  context do
    home '/home/rms'
    pwd '/home/rms/proj/emacs'
    exemplifying "pwd is in home, relpath wins" do
      o '/home/rms/proj/hurd',   '../hurd'
    end
  end
end
