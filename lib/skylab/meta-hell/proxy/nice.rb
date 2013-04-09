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

  module Proxy::Nice::Basic

    # another goofball experiment - make a ::BasicObject s.c that is nice
    # NOTE do not just create your produced subclass with Basic.new and
    # expect it to work like a functional proxy! This simply produces
    # a ::BasicObject subclass that a) does the nice things and b) makes
    # a constructor (if you have nonzero length members in your definition)
    # that takes a hash yet passes ordered args to *your* `initialize`
    # This, in contrast to working with functional proxies, makes no
    # assumptions about how you want to implement you proxy.

    def self.new *a
      valid = if a.length.nonzero? then ::Struct.new(* a ).new end
      kls = ::Class.new ::BasicObject
      def kls.inherited kls2
        kls2.send :define_method, :class do kls2 end
      end
      kls.class_exec do
        define_method :class do kls end
        if valid
          define_method :inspect do
            "#<#{ self.class } #{ valid.members.join ', ' }>"
          end
          define_method :initialize do |*args|
            # (internal sanity check - affects test only, compat for 1.9.3)
            args.length == a.length or raise ::ArgumentError, "wrong number #{
              }of arguments (#{ args.length } for #{ a.length })"
          end
          define_singleton_method :new do |h|
            h.keys.each { |k| valid[ k ] }              # all keys are valid
            args = valid.members.map { |k| h.fetch k }  # no keys are missing
            obj = allocate
            obj.__send__ :initialize, *args
            obj
          end
        else
          define_method :inspect do
            "#<#{ self.class }>"
          end
          define_singleton_method :new do
            obj = allocate
            obj.__send__ :initialize
            obj
          end
        end
      end
      kls
    end
  end
end
