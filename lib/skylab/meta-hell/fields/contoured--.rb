module Skylab::MetaHell

  module Fields

    module Contoured__

      # use it
      # like so:
      #
      #     class Foo
      #       MetaHell::Fields.contoured self,
      #         :globbing, :absorber, :with,
      #         :proc, :foo,
      #         :memoized, :proc, :bar,
      #         :method, :bif,
      #         :memoized, :method, :baz
      #     end
      #
      #     # one line #until:[#ts-032]
      #
      #     foo = Foo.new ; foo.with :foo, -> { :yes } ; foo.foo  # => :yes
      #
      # and so:
      #
      #     @ohai = :hi
      #     f = Foo.new ; f.with(  :foo, -> { 'x' },
      #                              :bar, -> { "y:#{ @ohai }" },
      #                              :bif, -> { "_#{ foo }_" },
      #                              :baz, -> { "<#{ foo }>" } )
      #     f.foo  # => 'x'
      #     f.bar  # => 'y:hi'
      #     f.bif  # => '_x_'
      #     ( f.baz.object_id == f.baz.object_id )  # => true
      #
      #

      class << self
        def [] client, *a
          from_iambic_and_client a, client
        end
        def from_iambic_and_client a, client
          Shell__.new( client ).with_iambic_absorbed_fully( a ).flush
        end
      end

      class Shell__

        def initialize client
          @client = client
          @field_box = nil
        end

        def with_iambic_absorbed_fully x_a
          @d = 0 ; @x_a = x_a ; len = x_a.length
          begin
            send OP_H__.fetch @x_a.fetch @d
          end while @d < len
          self
        end
        #
        OP_H__ = {  # near [#064]
          absorber: :parse_absorber,
          field: :parse_field,
          globbing: :parse_absorber,
          memoized: :parse_memoized,
          method: :parse_method,
          overriding: :parse_absorber,
          passive: :parse_absorber,
          private: :parse_absorber,
          proc: :parse_proc,
          required: :parse_required
        }.freeze

        def flush
          @field_box or field_box
          MetaHell_::Fields::Touch_const_with_dupe_for___[ -> _ do
            p = Required_fields_check__[ @field_box ]
            @client.facet_muxer.add_hook_listener :post_absorb, p
            p
          end, :CONTOURED_REQUIRED_CHECK_, @client ] ; nil
        end
        #
        Required_fields_check__ = -> field_box do  # on dupe, rewrite the func
          on_dupe_for = -> client do
            Dupable_Proc__.new on_dupe_for, &
              Req_check__[ client.const_get CONST__ ]
          end
          Dupable_Proc__.new on_dupe_for, & Req_check__[ field_box ]
        end
        CONST__ = MetaHell_::Fields::CONST_
        #
        Req_check__ = -> field_box do
          -> agent do
            miss_a = field_box._a.reduce [] do |m, method_i|
              (( fld = field_box.fetch method_i )).is_required or next m
              agent.instance_variable_defined? fld.ivar and
                ! agent.instance_variable_get( fld.ivar ).nil? and next m
              m << fld
            end
            miss_a.length.nonzero? and
              Missing_required_fields_notify_[ agent, miss_a ]
            nil
          end
        end
        #
        class Dupable_Proc__ < ::Proc
          class << self ; alias_method :[], :new end
          def initialize on_dupe_for, &blk
            super( &blk )
            @on_dupe_for = on_dupe_for ; nil
          end
          def dupe_for x
            @on_dupe_for[ x ]
          end
        end
        #
        Missing_required_fields_notify_ = -> agent, miss_a do  # etc
          s, op, cp = 1 == miss_a.length ? EMPTY_A_ : %w[ s ( ) ]
          raise ::ArgumentError, "missing required argument#{ s } - #{ op }#{
            }#{ miss_a.map( & :method_i ) * ', ' }#{ cp }"
          nil
        end

      private

        def field_box
          @field_box ||= bld_field_box
        end

        def bld_field_box
          MetaHell_::Fields::Box_for.client @client
        end

        def parse_absorber
          d, item = MetaHell_::Fields::Absorber_Method_.
            unobtrusive_passive_scan @d - 1, @x_a
          d or raise ::ArgumentError, "syntax mixmatch near '#{ @x_a[ @d ] }'"
          item.apply_to_client @client
          @d = d + 1 ; nil
        end

        def parse_proc
          accept_name_and_add_proc_field.flush @client ; nil
        end

        def parse_method
          accept_name_and_add_method_field.flush @client ; nil
        end

        def parse_memoized
          parse_with_branch MEMOIZED_BRANCH__
        end

        MEMOIZED_BRANCH__ = {
          proc: :parse_memoized_proc,
          method: :parse_memoized_method }.freeze

        def parse_with_branch h
          send h.fetch @x_a.fetch @d += 1
        end

        def parse_memoized_proc
          accept_name_and_add_proc_field do |fld|
            fld.is_memoized = true
          end.flush @client ; nil
        end

        def parse_memoized_method
          accept_name_and_add_method_field do |fld|
            fld.is_memoized = true
          end.flush @client ; nil
        end

        def accept_name_and_add_proc_field &blk
          accept_name_and_add_field_with_class_and_block Proc__, blk
        end

        def accept_name_and_add_method_field &blk
          accept_name_and_add_field_with_class_and_block Method__, blk
        end

        def accept_name_and_add_field_with_class_and_block cls, p
          field_bx = field_box
          method_i = @x_a.fetch @d + 1
          @d += 2
          fld = cls.new method_i, p
          field_bx.add method_i, fld
          fld
        end
        # (was: [#062] "i just blue myself")
      end

      Aspect_ = MetaHell_::Fields::Aspect_  # until [#061]

      class Procesque__ < Aspect_
        def initialize( * )
          @is_memoized = false
          super
        end
        attr_accessor :is_memoized
        def absorb_into_client_iambic client, a
          prock = a.fetch( 0 ) ; a.shift
          prock.respond_to? :call or fail "sanity - #{ prock.class }"
          client.instance_variable_set @ivar, prock ; nil
        end
      end

      class Proc__ < Procesque__
        def flush client
          ivar = @ivar
          if @is_memoized
            did = value = nil
            client.send :define_method, @method_i do
              if did then value else
                did = true
                value = instance_variable_get( ivar ).call  # etc
              end
            end
          else
            client.send :define_method, @method_i do
              instance_variable_get( ivar ).call  # etc
            end
          end
        end
      end

      class Method__ < Procesque__
        def flush client
          ivar = @ivar
          if @is_memoized
            did = value = nil
            client.send :define_method, @method_i do
              if did then value else
                did = true
                value = instance_exec( & instance_variable_get( ivar ) )
              end
            end
          else
            client.send :define_method, @method_i do
              instance_exec( & instance_variable_get( ivar ) )  # etc
            end
          end
        end
      end

    # [ `required` ] `field`s -
    #
    # failing to pass a required field triggers an argument error
    #
    #     class Foo
    #       MetaHell::Fields.contoured self,
    #         :overriding, :globbing, :absorber, :initialize,
    #         :required, :field, :foo, :field, :bar
    #     end
    #
    #     Foo.new  # => ArgumentError: missing required argument - foo
    #
    # passing nil is considered the same as not passing an argument
    #
    #     Foo.new( :foo, nil )  # => ArgumentError: missing required argument - foo
    #
    # passing false is not the same as passing nil, passing false is valid.
    #
    #     Foo.new( :foo, false ).foo  # => false
    #
    # you can of course pass nil as the value for a non-required field
    #
    #     Foo.new( :foo, :x, :bar, nil ).bar  # => nil
    #

      class Field__ < Aspect_
        attr_writer :is_required  # not pushed up yet
        def flush client
          client.send :attr_reader, @method_i
        end
        def absorb_into_client_iambic client, a
          x = a.fetch 0 ; a.shift
          client.instance_variable_set @ivar, x ; nil
        end
      end

      class Shell__
      private
        def parse_required
          parse_with_branch REQUIRED_BRANCH__
        end
        REQUIRED_BRANCH__ = {
          field: :parse_required_field }.freeze

        def parse_field
          take_name_and_add_field.flush @client ; nil
        end
        def parse_required_field
          take_name_and_add_field do |fld|
            fld.is_required = true
          end.flush @client ; nil
        end
        def take_name_and_add_field &blk
          accept_name_and_add_field_with_class_and_block Field__, blk
        end
      end
    end
  end
end
