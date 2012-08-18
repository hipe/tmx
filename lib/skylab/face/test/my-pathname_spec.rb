require_relative 'test-support'

describe "#{Skylab::Face::MyPathname}#pretty" do


  # --*-- enjoy
  MEMO = { }
  WITH = ->(name, *v) { v.empty? ? MEMO[name] : (MEMO[name] = v.first) }
  THESE = [:HOME, :PWD]
  def self.frame(&b) ; MEMO.clear ; instance_eval(&b) end
  def self.home(*v) ; WITH.call(:HOME, *v) end
  def self.pwd(*v) ; WITH.call(:PWD, *v) end
  def self.exemplifying desc, *tags, &block
    memo = MEMO.dup
    before_f = -> do
      THESE.each { |k| ::Skylab::Face::PathTools::const_get("CLEAR_#{k}").call }
      memo.each do |k, v|
        ::Skylab::Face::PathTools::const_get(k).singleton_class.send(
          :define_method, :call) { v }
      end
      (THESE - memo.keys).each do |k|
        ::Skylab::Face::PathTools::const_get(k).singleton_class.send(
          :define_method, :call) { } # application code is expected to then not
                                     # use such undefined values
      end
    end
    context(desc, *tags) do
      before(:all) { before_f.call }
      instance_exec(&block)
    end
  end
  def self.o input, expected, *a
    msg = (input == expected ? 'does not change' : "prettifies to #{expected.inspect}")
    it("#{input.inspect} #{msg}", *a)  do
      ::Skylab::Face::MyPathname.new(input).should prettify_to(expected)
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
end
