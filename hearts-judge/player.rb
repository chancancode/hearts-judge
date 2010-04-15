require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'array_extension.rb'

module Hearts
  # An abstract class that implements the player API with some default behavior
  class Player
    attr_reader :id, :name, :points
        
    def initialize(id, name, game)
      @id = id
      @name = name
      @points = 0
      @game = game
      @cards = []
      
      $logger.info("Player #{@id} is now known as #{self}")
    end
    
    # Reference to other players
    def neighbour(direction)
      case direction
        when :left then @game.players[(@id+1)%4]
        when :right then @game.players[(@id+2)%4]
        when :across then @game.players[(@id-1)%4]
        when :nopass then self
      end
    end
    
    # Receive the hand from the judge
    def deal_cards(cards)
      @cards = cards
    end
    
    # Pick three cards to pass
    def request_pass(player,direction)
      $logger.warn("Subclass of Player (#{self}) did not override request_pass")
      @cards.slice!(1...3) unless player == self
    end
    
    # Receive the cards passed on to you 
    def receive_pass(player,cards)
      @cards = cards + @cards unless player == self
    end
    
    # Start the game with a C2
    def request_start(trick)
      play(trick,C2)
    end
    
    # Pick a card to play
    def request_play(trick)
      # Override me
      raise 'Subclass of Player must override request_play.'
    end
    
    def trick_summary(trick)
    end
    
    # Callback for winning a trick (taking the points)
    def won_trick(trick)
      $logger.info("#{self} took #{trick.points} points")
      @points += trick.points
    end
    
    # Callback for game ended
    def game_ended
    end
    
    # Play a card
    def play(trick,card,validation=true)
      card = validate(trick,card) if validation
      $logger.info("#{self} is playing a #{card}")
      trick << @cards.delete(card)
    end
    
    # Do I have this card?
    def has?(card)
      @cards.include? card
    end
    
    # Clean up
    def kill!
    end
    
    def to_s
      @name + " (player #{@id})"
    end
    
    protected
    
    # Check if the card is valid for this trick. If not, pick a valid one
    def validate(trick,card)
      $logger.debug("Validating #{card}: suit=#{trick ? trick.suit : 'N/A'}, heart_broken=#{@game.heart_broken?}") 
      
      # Find all valid cards
      valid = @cards
      
      if trick.nil?
        # Do nothing
      elsif trick.empty?
        # We are starting a trick
        
        if @game.new?
          # If we are starting a GAME, then only C2 is valid
          valid = [C2]
        elsif not @game.heart_broken?
          # Filter out the hearts
          no_hearts = @cards.reject { |c| c.hearts? }
          valid = no_hearts unless no_hearts.empty?
        end
      else
        # Try to follow the suit
        in_suit = @cards.find_all { |c| c.suit == trick.suit }
        valid = in_suit unless in_suit.empty?
        
        # No point cards in the first round
        if @game.new?
          non_points = valid.reject { |c| c.points? }
          valid = non_points unless non_points.empty?
        end
      end
      
      if valid.include? card
        $logger.debug("#{card} is valid") 
        card
      else
        $logger.debug("#{card} is invalid") 
        valid.randomly_pick
      end
    end
  end
end