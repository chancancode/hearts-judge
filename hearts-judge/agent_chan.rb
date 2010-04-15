require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'

module Hearts
  class AgentChan < Player    
    def initialize(id, game)
      super(id,'Agent Chan',game)
    end
    
    # Pick three cards to pass
    def request_pass(player,direction)
      sort_hand_by_rank!
      @cards.slice(0...3)
    end
    
    # Pick a card to play
    def request_start(trick)
      C2
    end
    
    # Pick a card to play
    def request_play(trick)
      choices = sort_by_rank(valid_cards(trick))
      
      return choices.first if choices.count == 1 # No choice
      return choices.first if trick.number == 0 # Play largest in first round
      return choices.last if trick.empty? # Always play smallest if starting
      
      if choices.first.suit != trick.suit
        # We're free to play anything, get rid of the most unwanted card
        return choices.first
      else
        # We are following a suit...
        
        if trick.high_card && choices.last > trick.high_card
          # We are forced to take the trick, play most unwanted card
          return choices.first
        else
          # We are following a suit...
          
          if trick.count == 3
            # We are the last to play
            if trick.points?
              return play_safe(trick,choices)
            else
              return choices.first
            end
          end
          
          # Check if the remaining players are all out of the suit
          all_out = true
          
          # We are either 2nd or 3rd to play
          all_out = all_out && neighbour(:left).out_of?(trick.suit)
          all_out = all_out && neighbour(:left).neighbour(:left).out_of?(trick.suit) if trick.count == 1
          
          return play_safe(trick,choices) if all_out
          
          # TODO...
          
          if trick.count == 1
            if trick.number < 4
              if trick.suit == HEARTS
                return risk_it(trick,choices,4)
              elsif trick.suit == SPADES
                if trick.points?
                  return risk_it(trick,choices,6)
                else
                  return risk_it(trick,choices,JACK)
                end
              else
                return risk_it(trick,choices)
              end
            else
              return play_safe(trick,choices)
            end
          else
            if trick.number < 6
              if trick.suit == HEARTS
                return risk_it(trick,choices,5)
              elsif trick.suit == SPADES
                if trick.points?
                  return risk_it(trick,choices,6)
                else
                  return risk_it(trick,choices,JACK)
                end
              else
                if trick.points?
                  return risk_it(trick,choices,7)
                else
                  return risk_it(trick,choices,JACK)
                end
              end
            else
              return play_safe(trick,choices)
            end
          end
        end
      end
    end
    
    def card_played(trick,card)
      @cards.delete(card)
      trick << card
      trick.next_player!
    end
    
    private
    
    def sort_hand_by_rank!
      @cards = sort_by_rank(@cards).reverse!
    end
    
    def sort_by_rank(cards)
      cards.sort_by{|c|c.rank_score}.reverse!
    end
    
    def play_safe(trick,choices)
      choices.each do |c|
        return c if c < trick.high_card            
      end
    end
    
    def risk_it(trick,choices,threshold=ACES)
      return choices.first if threshold == ACES
      choices.each do |c|
        return c if c < trick.high_card || (c.rank <= threshold && c.rank != ACES)
      end
      raise "SOMEHOW I FELL THROUGH... #{choices.map!{|c|c.to_s}.join ' '}; #{trick.cards.map!{|c|c.to_s}.join ' '}; #{threshold}"
    end
  end
end