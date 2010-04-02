require 'array_extension.rb'

module Hearts
  class HumanPlayer
    attr_reader :id
    
    def initialize(id)
      $logger.info("Player #{id} is a human player.")
      
      @id = id
      @cards = []
    end
    
    def deal_cards(cards)
      @cards = cards.sort!
      show_hand
    end
    
    def request_pass(to, direction)
      unless direction == :nopass
        show_hand
        puts "Player #{@id}, please pass THREE cards to your #{direction} (player #{to}):"
        c = [get_card,get_card,get_card]
        
        c.map! do |e|
          @cards.delete validate(e, nil, true)
        end
        
        puts "Player #{@id} is passing #{c.join ' '} to his #{direction} (player #{to})."
        $stdin.gets
        c
      end
    end
    
    def receive_pass(from, cards)
      @cards += cards
      @cards.sort!
      puts "Player #{@id}, you received #{cards[0...3].join ' '} from player #{from}."
      show_hand
      $stdin.gets
    end
    
    def request_start
      puts "Player #{@id} started the game by playing a C2." 
      $stdin.gets
      @cards.delete Card.from_string('C2')
    end
    
    def request_play(trick_no, starter, trick_cards, heart_broken)
      puts "Round #{trick_no} started with player #{starter}, current trick is #{trick_cards.join ' '}."
      puts heart_broken ? "The heart has already been broken." : "The heart has yet to be broken."
      show_hand
      puts "Player #{@id}, please play a card:"
      suite = trick_cards[0].nil? ? nil : trick_cards[0].suite
      c = validate(get_card, suite, heart_broken)
      puts "Player #{@id} is playing a #{c}."
      $stdin.gets
      @cards.delete c
    end
    
    def round_summary(trick_no, starter, trick_cards, heart_broken, winner, points)
      puts "Round #{trick_no} started with player #{starter}, the trick is #{trick_cards.join ' '}."
      puts heart_broken ? "The heart has already been broken." : "The heart has yet to be broken."
      puts "Player #{winner} won this trick, gained #{points} points."
      $stdin.gets
    end
    
    def game_summary(points)
    end
    
    def has?(card)
      card = Card.from_string(card) if card.is_a? String
      @cards.include? card
    end
    
    def kill!
    end
    
    private
    
    def get_card
      Card.from_string($stdin.gets.chomp!)
    end
    
    def validate(card, suite, allows_hearts)
      r = card
      
      until has?(r) &&
            (suite.nil? || r.suite == suite || out_of?(suite)) &&
            (r.suite != 'H' || allows_hearts || (suite.nil? && all_hearts?) || out_of?(suite))
        r = @cards.randomly_pick(1)[0]
      end
      
      puts "#{card} is not a valid choice, picking a random card #{r} instead." unless r == card
      
      r
    end
    
    def out_of?(suite)
      return false if suite.nil?
      @cards.all? { |card| card.suite != suite } 
    end
    
    def all_hearts?
      @cards.all? { |card| card.suite == 'H' }
    end
    
    def show_hand
      puts "Player #{@id}, here is your hand:"
      puts @cards.join ' '
    end
  end
end