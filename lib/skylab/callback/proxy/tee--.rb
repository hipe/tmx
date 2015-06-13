module Skylab::Callback

  module Proxy

    class Tee__ < ::BasicObject

      class << self

        alias_method :orig_new, :new

        def new * a, & p
          via_arglist_and_proc a, p
        end

        def call_via_arglist a, & p
          if a.length.nonzero? || p
            via_arglist_and_proc a, p
          else
            self
          end
        end

        def via_arglist_and_proc _I_A_, cls_p

          _I_A_.freeze

          ::Class.new( self ).class_exec do

            class << self
              alias_method :new, :orig_new
            end
            define_singleton_method :method_names do
              _I_A_
            end

            _I_A_.each do |i|
              define_method i do | * x_a, & p |
                @muxer.mux i, x_a, p
              end
            end

            _TEE_ID_ = Next_id__[]
            desc_p = -> do
              "#<#{ name }:(generated tee class #{ _TEE_ID_ })>"
            end  # basic objects don't respond to `class`, basic objects don't care

            define_method :initialize do
              @muxer = Muxer__.new desc_p
            end

            _H_ = nil
            define_method :respond_to? do |i|  # because we don't have `class`
              _H_ ||= ::Hash[ _I_A_.map { |i_| [ i_, nil ] } ]
              _H_.key? i
            end

            cls_p and class_exec( & cls_p )

            self
          end
        end

        Next_id__ = -> do
          id = 0
          -> { id += 1 }
        end.call

      end # >>

      def nil?  # if you are proxying to actual nil, go somewhere else
        false
      end

    # as a compromise for readable code and easier debugging, we make it
    # hard for you to proxy out the following methods. alternatives include
    # either making a 'pure proxy' that has an external controller object,
    # or passing in all the downstream children at construction time. both
    # were deemed unideal attotw.
    #

      def [] i
        @muxer.fetch i
      end

      def []= i, x
        @muxer.add i, x
      end

      def to_s
        @muxer.description
      end

      def muxer_
        @muxer
      end

      alias_method :inspect, :to_s  # (makes errors more traceable)

      def method i
        -> * a, & p do
          __send__ i, * a, & p
        end
      end

      class Muxer__ < Box

        def initialize desc_p
          super()
          @desc_p = desc_p
        end

        def description
          @desc_p.call
        end

        def mux meth_i, a, p

          d = -1
          last = @a.length - 1

          if d < last
            first_x = @h.fetch( @a.fetch d += 1 ).__send__ meth_i, * a, & p
          end

          while d < last
            @h.fetch( @a.fetch d += 1 ).__send__ meth_i, * a, & p
          end

          first_x
        end
      end
    end
  end
end
