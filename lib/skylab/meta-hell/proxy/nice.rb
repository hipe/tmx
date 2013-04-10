module Skylab::MetaHell
                                  # ( we find ourselves making a lot of
                                  # functionial proxies like this )
  module Proxy::Nice

    def self.new *member_a

      Proxy::Functional.new( *member_a ).class_exec do

        def self.new h
          o = allocate
          o.__send__ :initialize, h
          sc = class << o ; self end
          kls = self
          sc.class_exec do
            define_method :class do kls end

            define_method :inspect do
              ary = kls::MEMBER_A_.reduce [ ] do |m, member|
                m << member
              end
              "#<#{ kls } #{ ary.join ', ' }>"
            end
          end
          o
        end
        self
      end
    end
  end

  module Proxy::Nice::Basic

    # another goofball experiment - make a ::BasicObject s.c that is nice
    # NOTE do not just create your produced subclass with Basic.new and
    # expect it to work like a functional proxy! This simply produces
    # a ::BasicObject subclass that a) does the nice things and b) makes
    # a constructor (if you have nonzero length members in your definition)
    # that takes a hash yet passes ordered args to *your* `initialize`
    # (hence your `initialize` *must* take the same number of arguments
    # as the number of members your produced your proxy class with).

    # This, in contrast to working with functional proxies, makes no
    # assumptions about how you want to implement you proxy. It basically
    # just produces a glorified ::BasicObject subclass that does the two
    # nice things and does the constructor arg parsing.

    def self.new *member_a

      if member_a.length.nonzero?
        has_members = true
        member_a.freeze
      end

      ::Class.new( ::BasicObject ).class_exec do
        kls = self

        def self.inherited kls2
          kls2.send :define_method, :class do kls2 end
        end

        define_method :class do kls end

        if has_members
          define_method :inspect do
            "#<#{ self.class } #{ member_a * ', ' }>"
          end
        else
          define_method :inspect do
            "#<#{ self.class }>"
          end
        end

        if has_members
          argmnt_a = ::Array.new( member_a.length ).freeze
          remain_a = 0.upto( member_a.length - 1 ).to_a.freeze

          define_singleton_method :new do |h|
            arg_a = argmnt_a.dup
            rmn_a = remain_a.dup
            member_a.each_with_index do |k, i|
              arg_a[ i ] = h.fetch k
              rmn_a[ i ] = nil
            end
            rmn_a.compact!
            rmn_a.length.nonzero? and ::Kernel.raise ::ArgumentError, "you #{
              }must provide (#{ rmn_a.map( & member_a.method(:fetch)) * ', ' })"
            obj = allocate
            obj.__send__ :initialize, *arg_a
            obj
          end
        else
          define_singleton_method :new do
            obj = allocate
            obj.__send__ :initialize
            obj
          end
        end

        self
      end
    end
  end
end
