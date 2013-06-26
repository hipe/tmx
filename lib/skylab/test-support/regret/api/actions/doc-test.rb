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

    params :path, [ :template_options, :arity, :zero_or_one ],
      API::Conf::Verbosity[ self ].param( :vtuple )

    def execute
      sn = @vtuple.make_snitch @err
      bs = DocTest::Comment_::Block::Scanner[ sn, ::File.open( @path, 'r' ) ]
      sp = DocTest::Specer_.new sn, @out, :quickie, @path
      -> do
        sp.set_template_options @template_options or break( false )
        while cblock = bs.gets
          cblock.describe_to @err if @vtuple.do_murmur
          if cblock.does_look_testy
            sp.accept cblock
          end
        end
        r = sp.flush or break r
        if @vtuple.do_medium
          sn.puts "finished generated output for #{ @path }"
        elsif @vtuple.do_notice
          sn.puts 'done.'
        end
        nil
      end.call
    end

    # this mess is used by our many children, we have a bit of a branch node
    Basic = Basic
    DocTest = self ; Face = Face
    MetaHell = MetaHell
    SEP = '# =>'

  end
end
