require 'test/unit'

class HouseTest < Test::Unit::TestCase
  class House
    VERSE_MAPPING = [
        'the horse and the hound and the horn that belonged to',
        'the farmer sowing his corn that kept',
        'the rooster that crowed in the morn that woke',
        'the priest all shaven and shorn that married',
        'the man all tattered and torn that kissed',
        'the maiden all forlorn that milked',
        'the cow with the crumpled horn that tossed',
        'the dog that worried',
        'the cat that killed',
        'the rat that ate',
        'the malt that lay in',
        'the house that Jack built'
    ]

    def initialize(verseModifiers = [])
      @verseModifiers = verseModifiers
    end
    def verses
      @verseModifiers.inject(VERSE_MAPPING) {|v, t| t.modify(v)}
    end

    def verse(num)
      lines = verses.last(num)
      "This is #{lines.join(' ')}.\n"
    end

    def recite
      1.upto(VERSE_MAPPING.length).map {|n| verse(n)}.join "\n"
    end
  end

  class DoublerModifier
    def modify(data)
      data.map {|line| "#{line} #{line}"}
    end
  end

  class InvertModifier
    def modify(data)
      data.reverse
    end
  end

  test "verses" do
    rhyme = House.new

    assert_equal rhyme.verse(1), "This is the house that Jack built.\n"
    assert_equal rhyme.verse(2), "This is the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(3), "This is the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(4), "This is the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(5), "This is the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(6), "This is the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(7), "This is the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(8), "This is the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(9), "This is the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(10), "This is the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(11), "This is the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
    assert_equal rhyme.verse(12), "This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"
  end
  
  test "doubler" do
    rhyme = House.new([DoublerModifier.new])

    assert_equal rhyme.verse(1), "This is the house that Jack built the house that Jack built.\n"
    assert_equal rhyme.verse(2), "This is the malt that lay in the malt that lay in the house that Jack built the house that Jack built.\n"
  end

  test "inverted" do
    rhyme = House.new([InvertModifier.new])

    assert_equal rhyme.verse(1), "This is the horse and the hound and the horn that belonged to.\n"
    assert_equal rhyme.verse(2), "This is the farmer sowing his corn that kept the horse and the hound and the horn that belonged to.\n"
  end

  test "multiple" do
    rhyme = House.new([InvertModifier.new, DoublerModifier.new])

    assert_equal rhyme.verse(1), "This is the horse and the hound and the horn that belonged to the horse and the hound and the horn that belonged to.\n"
    assert_equal rhyme.verse(2), "This is the farmer sowing his corn that kept the farmer sowing his corn that kept the horse and the hound and the horn that belonged to the horse and the hound and the horn that belonged to.\n"
  end

  test "recite" do
    rhyme = House.new
    expected = ""
    expected << "This is the house that Jack built.\n\n"
    expected << "This is the malt that lay in the house that Jack built.\n\n"
    expected << "This is the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n\n"
    expected << "This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.\n"

    assert_equal expected, rhyme.recite
  end
end

