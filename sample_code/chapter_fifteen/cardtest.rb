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
# Run options: --seed 59230
# # Running:
# F
# Failure:
# CardTest#test_deal_many [cardtest.rb:14]:
# Expected: 47
#   Actual: 43
#
# bin/rails test cardtest.rb:12
# F
# Failure:
# CardTest#test_deal_one [cardtest.rb:10]:
# Expected: 51
#   Actual: 47
# bin/rails test cardtest.rb:8
# Finished in 0.002925s, 683.8767 runs/s, 683.8767 assertions/s.
# 2 runs, 2 assertions, 2 failures, 0 errors, 0 skips
