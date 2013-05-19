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

    params :path, API::Conf::Verbosity.parameter

    API::Conf::Verbosity self

    def execute
      fh = ::File.open @path, 'r'
      cs = DocTest::Comment_::Block::Scanner[ fh ]  # yay.
      sp = DocTest::Specer_.new :quickie, @out, @err, @path, @vtuple
      while cblock = cs.gets
        cblock.describe_to @err if @do_verbose_murmur
        if cblock.does_look_testy
          sp.accept cblock
        end
      end
      sp.flush
      if @do_verbose_medium
        @err.puts "finished generated output for #{ @path }"
      elsif @do_verbose_everything
        @err.puts 'done.'
      end
      nil
    end

    # this mess is used by our many children, we have a bit of a branch node
    Basic = Basic
    DocTest = self ; Face = Face
    MetaHell = MetaHell
    SEP = '# =>'

  end
end
