                     # (today we are being super OCD about loading this
                     # because of thorny issues encountered in the past with
                     # the git environment not being the same the as the
                     # environment we develop in. we want to be really explicit
                     # and careful about checking for the appropriate ruby
                     # versions b/c it's awful-looking to fail from "inside"
                     # git. Oh.. wait a minute.. look how i just wrote this. fuu


min_version = [1, 9, 2]

                      # also, a tangent:

compare = -> a, b do  # `a` and `b` are arrays of comparables.  find which
  res = 0             # array is "greater" where the most significant parts
                      # are at lower indexes in the array.

  if a.length < b.length                       # (`zip` is not symmetrical so
    (a = a.dup)[ b.length - 1] = nil           # `a` must be at least as long
  end                                          # as `b but not the reverse)

  a.zip( b ).index do |_a, _b|
    if _a
      if _b
        i = _a <=> _b
        if 0 == i
          nil        # `a` and `b` are same at this part, keep looking
        else
          res = i    # we found a part where `a` and `b` differ, so we
          true       # can use that as our result and stop looking.
        end
      else
        res = 1      # `b` is nil at this part, hence `a` is longer than `b`
        true         # hence more granular hence `a` is greater than `b`
      end
    else
      res = -1       # `a` is nil at this part, hence `b` is longer than `a`
      true           # hence more granular hence `a` is less than `b`
    end
  end
  res
end

serr = ::STDERR  # (avoid accessing resources as globals/constants)

error = -> msg do
  serr.puts msg
  nil
end

notice = -> msg do
  serr.puts "notice: #{ msg }"
  nil
end

program_name = -> { ::File.basename $PROGRAM_NAME }

res = false

begin
  if ! ::Object.const_defined? :RUBY_VERSION
    break error[ "no RUBY_VERSION constant!?" ]
  end

  rx = /\A\d+\z/
  version = ::RUBY_VERSION
  a = version.split( '.' ).map { |x| x.to_i if rx =~ x }
  if a.index { |x| ! x }          # version string has non-integer parts in it,
    notice[ "version has non-numeric parts, assuming it's ok: #{ version }" ]
    break( res = true )           # just assume the best!
  end
  if compare[ a, min_version ] < 0
    error[ "ruby version is too low (#{ version }), we need #{
      }at least version #{ min_version.join '.' } to run #{ program_name[] }" ]
    break
  end

  res = true
end while nil


if false == res
  error[ "sorry, #{ program_name[ ] } couldn't load because of #{
    }the above issue(s)." ]
  exit 1 # just being cute
elsif res.nil?
  # nothing
else
  basename = ::File.basename $PROGRAM_NAME
  require 'skylab/git'
  if 'git-stash-untracked' == basename
    d = Skylab::Git::CLI.new(
      ARGV, :_no_stdin_for_git_etc_, $stdout, serr, [ basename ]
    ).execute

    if d.nonzero?
      serr.puts "(exitstatus: #{ d })"
    end
    exit d
  else
    Skylab::TMX::OneOffs::Git_stash_untracked = -> * five do  # #[#tmx-018.1] mountable one-off
      Skylab::Git::CLI.new( * five ).execute
    end
  end
end
