require 'fileutils'
require 'shellwords'

module Skylab end
module Skylab::Face end
module Skylab::Face::PathTools
  home = home_re = pwd = pwd_re = pwd_re_2 = nil
  HOME = ->{ home ||= ::ENV['HOME'] }
  HOME_RE =  ->{ home_re ||= %r[\A#{::Regexp.escape HOME.call}(?=/|\z)] }
  CLEAR_HOME = ->{ home = home_re = nil }
  PWD = ->{ pwd ||= ::FileUtils.pwd }
  PWD_RE = ->{ pwd_re ||= %r[\A#{::Regexp.escape PWD.call}(?=/|\z)] }
  CLEAR_PWD = ->{ pwd = pwd_re = pwd_re_2 = nil }
  PWD_RE_2 = -> do # @todo sort this out
    pwd_re_2 ||=
      %r<\A#{ ::Regexp.escape(PWD.call.sub(%r<\A/private/>, '/')) }>
  end
  module InstanceMethods
    def beautify_path path ; path.sub(PWD_RE_2.call, '.') end
    def escape_path path
      / |\$|'/ =~ path.to_s ? ::Shellwords.shellescape(path) : path.to_s
    end
    def pretty_path path
      h = { home: HOME.call, pwd: PWD.call }
      if h[:home] && h[:pwd]
        k = if    0 == h[:home].index(h[:pwd]) then :home
            elsif 0 == h[:pwd].index(h[:home]) then :pwd  end
        if k and  0 == path.index(h[k])
          h[ :pwd == k ? :home : :pwd ] = false
        end
      end
      h[:home] and path = path.sub(HOME_RE.call, '~')
      h[:pwd]  and path = path.sub(PWD_RE.call, '.')
      path
    end
  end
end
