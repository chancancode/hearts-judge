require 'constants.rb'
require 'card.rb'

module Hearts
  class Trick
    attr_reader :number, :starter, :current_player, :cards
    
    def initialize(number, starter, heart_broken)
      @number = number
      @starter = starter
      @current_player = @starter
      @heart_broken = heart_broken
      @cards = []
      @points = 0
    end
    
    def next_player!
      @current_player = @current_player.neighbour(:left)
    end
    
    def hearts?
      @cards.any? { |c| c.hearts? }
    end
    
    def qos?
      # queen of spades
      @cards.include? S12
    end
    
    def points?
      @points > 0
    end
    
    def points
      @points
    end
    
    def count
      @cards.count
    end
    
    def empty?
      @cards.empty?
    end
    
    def full?
      @cards.count == 4
    end
    
    def suit
      empty? ? nil : @cards[0].suit
    end
    
    def in_suit
      @cards.find_all { |c| c.suit == suit }
    end
    
    def off_suit
      @cards.reject { |c| c.suit == suit }
    end
    
    def high_card
      in_suit.max
    end
    
    def winner
      return nil unless full?
      winner = @starter
      i = @cards.index(high_card)
      i.times { winner = winner.neighbour(:left) }
      winner
    end
    
    def <<(card)
      raise 'This trick cannot accept anymore cards!' if full?
      @cards << card
      @points += card.points
    end
  end
end