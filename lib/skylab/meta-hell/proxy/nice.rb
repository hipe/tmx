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
    #
    def self.new *a
      valid = ::Struct.new(* a ).new
      kls = ::Class.new ::BasicObject
      def kls.inherited kls2
        kls2.send :define_method, :class do kls2 end
      end
      kls.class_exec do
        define_method :class do kls end
        define_method :inspect do
          "#<#{ self.class } #{ valid.members.join ', ' }>"
        end
        define_singleton_method :new do |h|
          h.keys.each { |k| valid[ k ] }              # all keys are valid
          args = valid.members.map { |k| h.fetch k }  # no keys are missing
          obj = allocate
          obj.__send__ :initialize, * args
          obj
        end
      end
      kls
    end
  end
end
