require 'constants.rb'

module Hearts
  class Card
    include Comparable   
    attr_reader :suit, :rank
    
    @@cache = {}
    @@deck = []
    
    def initialize(suit,rank)
      @suit = suit
      @rank = rank
      @@cache[self.to_s] = self
    end
    
    def to_s
      Hearts.suit_to_string(@suit) + @rank.to_s
    end
    
    def error?
      @suit == ERROR
    end
    
    def hearts?
      @suit == HEARTS
    end
    
    def qos?
      @suit == SPADES && @rank == QUEEN
    end
    
    def points?
      points > 0
    end
    
    def points
      if hearts?
        1
      elsif qos?
        13
      else
        0
      end
    end
    
    def <=>(other)
      score <=> other.score
    end
    
    # For default sort (by suit then rank)
    
    def score
      if @rank == 1
        @suit * 100 + 14
      else
        @suit * 100 + @rank
      end
    end
    
    # For alternative sort (least unwanted to most unwanted)
        
    def rank_score
      return 9999 if self == S12 # Queen of spades
      return 8999 if self == S1  # Aces of spades
      return 7999 if self == S13 # King of spades
      return 6999 if self == H1  # Aces of hearts
      return 5999 + @rank if @suit == HEARTS && @rank > 6 # High hearts first
      return 4999 + @suit if @rank == ACES # Handle special case of aces (rank = 1)
      return 100 * @rank + 4 if @suit == HEARTS # Hearts should be the largest suit
      100 * @rank + @suit # Default
    end
    
    # Class methods
    
    def self.from_string(value)
      s = Hearts.string_to_suit(value[0...1])
      r = value[1..-1].to_i
      @@cache[value] ||= Card.new(s,r)
    end
    
    def self.deck
      if @@deck.empty?
        # Generate the 52 cards        
        [SPADES,HEARTS,CLUBS,DIAMONDS].each do |s|
          (1..13).each do |r|
            @@deck << Card.new(s,r)
          end
        end
        
        @@deck.freeze
      end
      
      @@deck.dup
    end
  end
end