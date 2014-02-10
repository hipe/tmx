module Skylab::Callback

  module Lib_  # :+[#ss-001]

    Basic_Digraph = -> do
      self::Basic__[]::Digraph
    end

    Basic_Hash = -> do
      self::Basic__[]::Hash
    end

    Basic_List = -> do
      self::Basic__[]::List
    end

    Basic_String = -> do
      self::Basic__[]::String
    end

    Bundle_Item_Grammar = -> do
      self::MetaHell__[]::Bundle::Item_Grammar
    end

    Bundle_Multiset = -> x do
      self::MetaHell__[]::Bundle::Multiset[ x ]
    end

    Class = -> do
      self::MetaHell__[]::Class
    end

    CLI = -> do
      self::Headless__[]::CLI
    end

    Formal_Box = -> do
      self::MetaHell__[]::Formal::Box
    end

    Function = -> do
      self::MetaHell__[]::Function
    end

    Fuzzy_const_get = -> modul, part do
      self::MetaHell__[]::Boxxy::Fuzzy_const_get[ modul, part ]
    end

    Inspect = -> do
      p = -> x do
        _LENGTH_OF_A_LONG_LINE = 120
        p = self::Basic__[]::FUN::Inspect__.curry[ _LENGTH_OF_A_LONG_LINE ]
        p[ x ]
      end
      -> x { p[ x ] }
    end.call

    Let = -> do
      self::MetaHell__[]::Let
    end

    Memoize = -> p do
      Memoize_[ p ]  # as you like it
    end

    Name = -> do
      self::Headless__[]::Name
    end

    Num2ord = -> x do
      self::Headless__[]::NLP::EN::Number::Num2ord[ x ]
    end

    Open_Box = -> do
      self::MetaHell__[]::Formal::Box::Open
    end

    OptionParser = -> do
      require 'optparse' ; ::OptionParser
    end

    Quickie = -> x do
      x.extend self::TestSupport__[]::Quickie
    end

    Scn = -> & p do
      self::Headless__[]::Scn.new( & p )
    end

    Some_stderr = -> do
      self::Headless__[]::System::IO.some_stderr_IO
    end

    StringScanner = -> do
      require 'strscan' ; ::StringScanner
    end

    Unstyle_styled = -> s do
      self::Headless__[]::CLI::Pen::FUN::Unstyle_styled[ s ]
    end

    Writemode = -> do
      self::Headless__[]::WRITEMODE_
    end

    sidesystem = -> i do
      Memoize_[ -> do
        Autoloader.require_sidesystem i
      end ]
    end
    Basic__ = sidesystem[ :Basic ]
    MetaHell__ = sidesystem[ :MetaHell ]
    Headless__ = sidesystem[ :Headless ]
    TestSupport_ = TestSupport__ = sidesystem[ :TestSupport ]
  end
end
