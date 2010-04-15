module Hearts
  # player positions
  NORTH = 0
  EAST  = 1
  SOUTH = 2
  WEST  = 3
  
  # suits
  SPADES = 0
  HEARTS = 1
  CLUBS  = 2
  DIAMONDS = 3
  ERROR   = -1
  UNKNOWN = -2
  
  # special cards
  JACK  = 11
  QUEEN = 12
  KING  = 13
  ACES  = 1
    
  # resolves constants into card objects, basically
  # allows us to reference a card as literals (S12, C2, etc)
  def Object.const_missing(name)
    card = Card.from_string(name.to_s)
    raise NameError, 'uninitialized constant' if card.error?
    card
  end
  
  # Helper methods
  
  def self.suit_to_string(suit)
    case suit
      when SPADES then 'S'
      when HEARTS then 'H'
      when CLUBS  then 'C'
      when DIAMONDS then 'D'
      when UNKNOWN then 'U'
      else 'E' #error
    end
  end
  
  def self.string_to_suit(string)
    case string
      when 'S' then SPADES
      when 'H' then HEARTS
      when 'C' then CLUBS
      when 'D' then DIAMONDS
      when 'U' then UNKNOWN
      else ERROR
    end
  end
end