module Skylab::Test

  class Plugins::Coverage

    Headless::Plugin.enhance self do

      eventpoints %i|
        available_options
        subtree
      |

      services :hot_subtree

    end

    def initialize
      @yep = false
    end

    available_options do |o, _|
      o.on '--coverage' do
        @yep = true
      end
    end

    subtree do |y|
      if @yep
        mgr = Manager.instance
        host.hot_subtree.children.each do |tre|
          if tre.children.to_a.length.nonzero?
            mgr.add_path y, tre.data.dir_pathname.to_s
          end
        end
      end
      nil
    end
  end
end
