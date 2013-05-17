module Skylab::TestSupport::Regret::API

  class API::Actions::DocTest < Face::API::Action

    # basic usage:
    #
    #     class Foo
    #       def bar
    #         :yes
    #       end
    #     end
    #
    #     Foo.new.bar  # => :yes
    #
    # there are other ways.
    # amazng ways.

    # more advanced usage:
    #
    #     class Foo
    #     end
    #     Foo.new.wat  # => NoMethodError: undefined method `wat' ..
    #
    # happy hacking!

    services [ :out, :ingest ],
             [ :err, :ingest ],
             [ :pth, :ingest ]

    params :path, [ :verbose_count, :normalizer, true ]

    def execute
      fh = ::File.open @path, 'r'
      cs = DocTest::Comment_::Block::Scanner[ fh ]  # yay.
      sp = DocTest::Specer_.new :quickie, @out, @err, @path, @vtuple
      while cblock = cs.gets
        cblock.describe_to @err if @do_verbose_everything
        if cblock.does_look_testy
          sp.accept cblock
        end
      end
      sp.flush
      if @do_verbose_medium
        @err.puts "finished generated output for #{ @path }"
      elsif @do_verbose_murmur
        @err.puts 'done.'
      end
      nil
    end

    DocTest = self ; Face = Face ; MetaHell = MetaHell
    Basic = Face::Services::Basic

    SEP = '# =>'

    -> do  # `normalize_verbose_count` - implement "graded verbosity" [#fa-032]
      lvl_a = %i|
        murmur
        medium
        everything
      |.freeze
      ivar_a = lvl_a.map { |i| "@do_verbose_#{ i }" }
      len = lvl_a.length
      Verbosity_ = ::Struct.new( * lvl_a )
      define_method :normalize_verbose_count do |y, x, yes|
        x ||= 1
        if len < x
          @err.puts "(verbosity level #{ len } is the highest. #{
            }ignoring #{ x - len } of the verboses.)"
          x = len
        end
        vtuple = Verbosity_.new
        x.times do |i|
          vtuple[ lvl_a.fetch i ] = true
          instance_variable_set ivar_a.fetch( i ), true
        end
        ( len - 1 ).downto( x ) do |i|
          instance_variable_set ivar_a.fetch( i ), false
        end
        @vtuple = vtuple
        yes[ x ]
        true
      end
    end.call
  end
end
