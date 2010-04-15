require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'

module Hearts
  class OpaquePlayer < Player   
    attr_reader :tricks_won, :cards_played
    
    def initialize(id, game)
      # Call parent initializer
      super(id,"Opponent #{id}",game)
      
      @cards = [U0,U0,U0,U0,U0,U0,U0,U0,U0,U0,U0,U0,U0]
      @cards_played = []
      @tricks_won = []
      @cleared_suits = [false,false,false,false]
    end
    
    # Receive the cards passed on to you 
    def receive_pass(player,cards)
      @cards = cards + @cards.first(10)
    end
    
    # Callback for played a card
    def card_played(trick,card)
      @cards.delete_first(card) || @cards.delete_first(U0)
      @cards_played << card
      trick << card
      trick.next_player!
      
      if card.suit != trick.suit
        @cleared_suits[trick.suit] = true
      end
    end
    
    # Callback for winning a trick (taking the points)
    def won_trick(trick)
      @tricks_won << trick
      super
    end
    
    # I have this card!
    def has!(card)
      unless has?(card)
        @cards.delete_first(U0)
        @cards << card
      end
    end
    
    # Do I have this card? Just maybe?
    def maybe?(card)
      has?(card) || (! out_of?(card.suit) && has?(U0))
    end
    
    def out_of?(suit)
      @cleared_suits[suit]
    end
    
    private
    
    # Receive the hand from the judge
    def deal_cards(cards)
      raise 'deal_cards is not supported in OpaquePlayer'
    end
    
    # Pick three cards to pass
    def request_pass(player,direction)
      raise 'request_pass is not supported in OpaquePlayer'
    end
    
    # Start the game with a C2
    def request_start(trick)
      raise 'request_start is not supported in OpaquePlayer'
    end
    
    # Pick a card to play
    def request_play(trick)
      raise 'request_play is not supported in OpaquePlayer'
    end
    
    # Play a card
    def play(trick,card,validation=true)
      raise 'play is not supported in OpaquePlayer'
    end
    
    # Check if the card is valid for this trick. If not, pick a valid one
    def validate(trick,card)
      raise 'validate is not supported in OpaquePlayer'
    end
  end
end