require_relative 'test-support'

describe "#{Skylab::Face::MyPathname}#pretty" do

  def self.o input, output, *a
    msg = (input == output ? 'does not change' : "prettifies to #{output.inspect}")
    it("#{input.inspect} #{msg}", *a)  do
      pn = ::Skylab::Face::MyPathname.new(input)
      if respond_to?(:home)
        pn.instance_variable_set('@home', home) # nil will be overwritten, not false
      end
      if respond_to?(:pwd)
        me = self
        pn.singleton_class.send(:define_method, :pwd) { me.pwd }
      end
      pn.should prettify_to(output)
    end
  end

  (-> do
    home = '/home/rms'
    context "contracts home directories to '~' (home is #{home.inspect})" do
      let(:home) { home }
      o '/home/rms/foo', '~/foo'
      o '/home/rms/foo/bar.txt', '~/foo/bar.txt'
      o 'home/rms/whatever', 'home/rms/whatever'
      o '/home/rms', '~'
      o '/home/rms/', '~/'
      o 'something/home/rms', 'something/home/rms'
    end
  end).call

  (-> do
    pwd = '/usr/local'
    context "contracts present working directory to '.' (pwd is #{pwd.inspect})" do
      let(:home) { false } ; let(:pwd) { pwd }
      o '/usr/local/foo', './foo'
      o '/usr/local/foo/bar.txt', './foo/bar.txt'
      o 'usr/local/whatever', 'usr/local/whatever'
      o '/usr/local', '.'
      o '/usr/local/', './'
      o 'something/usr/local', 'something/usr/local'
    end
  end).call

  (-> do
    home = '/home/rms'
    context "and if pwd *is* home dir, home dir always wins" do
      let(:home) { home } ; let(:pwd) { home }
      o '/home/rms', '~'
      o '/home/rms/foo', '~/foo'
    end
  end).call

  (-> do
    home = '/a/b/c'
    pwd  = '/a/b'
    context "and if home dir (#{home}) is inside pwd (#{pwd}), home dir wins (shortest wins)" do
      let(:home) { home } ; let(:pwd) { pwd }
      o '/a/b/c/foo/bar', '~/foo/bar'
      o '/a/b/c/foo',     '~/foo'
      o '/a/b/c/',        '~/'
      o '/a/b/c',         '~'
      o '/a/b/',          './'
      o '/a/b',           '.'
      o '/a/',            '/a/'
      o 'a/b/c',          'a/b/c'
    end
  end).call

  (-> do
    home = '/home/rms'
    pwd  = '/home/rms/proj'
    context "BUT if pwd (#{pwd}) is inside home (#{home}), PWD wins (shortest wins)" do
      let(:home) { home } ; let(:pwd) { pwd }
      o '/home/rms/proj/emacs.c', './emacs.c'
      o '/home/rms/proj',         '.'
      o '/home/rms/pro',          '~/pro'
      o '/home/rms',              '~'
      o 'home/rms',               'home/rms'
    end
  end).call


end
