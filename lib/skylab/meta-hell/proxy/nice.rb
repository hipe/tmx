module Skylab::MetaHell
                                  # ( we find ourselves making a lot of
                                  # functionial proxies like this )
  module Proxy::Nice
    def self.new *a
      kls = Proxy::Functional.new(* a )
      kls.class_exec do           # (subclasses of the generated class,
        def self.new *a           # their instances respond to `class`)
          otr = allocate
          otr.__send__ :initialize, *a
          sc = class << otr ; self end
          me = self
          sc.class_exec do
            define_method :class do me end

            define_method :inspect do
              a = @functions.members.reduce [ ] do |memo, m|
                memo << m
              end
              "#<#{ me } #{ a.join ', ' }>"
            end
          end
          otr
        end
      end
      kls
    end
  end
end
