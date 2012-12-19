require_relative '../test-support'
require_relative 'for-rspec' # sorry


describe "#{ Skylab::Headless::CLI::PathTools }#pretty_path" do

  include ::Skylab::Headless # constants

  fun = self::Headless::CLI::PathTools::FUN

  @memo = { }

  singleton_class.send :attr_reader, :memo

  define_singleton_method :frame do |&b|
    memo.clear
    instance_exec( &b )
  end

  get_set = -> name, *a do
    case a.length
    when 0 ; memo.fetch name
    when 1 ; memo[name] = a.first
    else   ; fail 'no'
    end
  end

  define_singleton_method :home do |*a|
    get_set[ :home, *a ]
  end

  define_singleton_method :pwd do |*a|
    get_set[ :pwd, *a ]
  end

  define_singleton_method :exemplifying do |s, *t, &b|
    home = memo[:home] # nil ok
    pwd = memo[:pwd] # nil ok
    _home = -> do
      home # acccesses this once per frame! -- could be tested
    end
    _pwd = -> do
      pwd # accesses this once per frame! -- could be tested
    end
    before_ = -> do
      fun.clear[ _home, _pwd ]
    end
    context s, *t do
      before :all do
        before_[]
      end
      instance_exec( &b )
    end
  end


  my_pathname = ::Class.new( ::Pathname )      # this is for testing and is not
  my_pathname.class_eval do                    # recommended for an application
    include ::Skylab::Headless::CLI::PathTools::InstanceMethods # -- it is poor
    def pretty                                 # separation of concerns to rely
      pretty_path to_s                         # on a pathname to decide how to
    end                                        # render itself.
  end

  define_singleton_method :o do |input, expected, *a|

    vp = if input == expected
      'does not change'
    else
      "prettifies to #{ expected.inspect }"
    end


    it "#{ input.inspect } #{ vp }", *a  do

      pn = my_pathname.new input
      pn.should prettify_to( expected )

    end

  end

  # --*--


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
