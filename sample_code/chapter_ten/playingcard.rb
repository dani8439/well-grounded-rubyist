class PlayingCard
  SUITS = %w{ clubs diamonds hearts spades }      #<---1.
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }
  class Deck
    attr_reader :cards                  #<---2.
    #3.
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|            #<---4.
        RANKS.cycle(1) do |r|             #<---5.
          @cards << "#{r} of #{s}"            #<---6.
        end
      end
    end
  end
end


# PlayingCard::Deck.new(1)
# #<PlayingCard::Deck:0x0000000227a6f8 @cards=["2 of clubs", "3 of clubs", "4 of clubs", "5 of clubs", "6 of clubs", "7 of clubs", "8 of clubs", "9
# of clubs", "10 of clubs", "J of clubs", "Q of clubs", "K of clubs", "A of clubs", "2 of diamonds", "3 of diamonds", "4 of diamonds", "5 of diamonds",
#  "6 of diamonds", "7 of diamonds", "8 of diamonds", "9 of diamonds", "10 of diamonds", "J of diamonds", "Q of diamonds", "K of diamonds", "A of diamo
# nds", "2 of hearts", "3 of hearts", "4 of hearts", "5 of hearts", "6 of hearts", "7 of hearts", "8 of hearts", "9 of hearts", "10 of hearts", "J of h
# earts", "Q of hearts", "K of hearts", "A of hearts", "2 of spades", "3 of spades", "4 of spades", "5 of spades", "6 of spades", "7 of spades", "8 of
# spades", "9 of spades", "10 of spades", "J of spades", "Q of spades", "K of spades", "A of spades"]>
