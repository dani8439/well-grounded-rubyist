require 'minitest/unit'
require 'minitest/autorun'
require_relative 'cards'
class CardTest < MiniTest::Unit::TestCase
  def setup
    @deck = PlayingCards::Deck.new
  end
  def test_deal_one
    @deck.deal
    assert_equal(51, @deck.size)
  end
  def test_deal_many
    @deck.deal(5)
    assert_equal(47, @deck.size)
  end
end

# Warning: you should require 'minitest/autorun' instead.
# Warning: or add 'gem "minitest"' before 'require "minitest/autorun"'
# From:
#   cardtest.rb:1:in `<main>'
# MiniTest::Unit::TestCase is now Minitest::Test. From cardtest.rb:4:in `<main>'
# Run options: --seed 54003
# Running:
# ..
# Finished in 0.001792s, 1115.9933 runs/s, 1115.9933 assertions/s.
# 2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
