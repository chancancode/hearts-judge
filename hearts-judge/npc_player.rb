require 'array_extension.rb'

module Hearts
  class NPCPlayer
    attr_reader :id
    
    def initialize(id, command)
      $logger.info("Player #{id}='#{command}'.")
      
      @pipe = IO.popen(command, 'r+')
      @id = id
      @cards = []
      
      # Test the agent...
      $logger.debug("Waiting for player #{@id} to get ready...")
      response = @pipe.gets.chomp!
      raise "Agent initialization error. Expecting 'READY\\n' from agent, got '#{response}'." unless response == 'READY'
      
      $logger.debug("Player #{id} is ready.")
      
      # Send player ID
      @pipe.puts @id
    end
    
    def deal_cards(cards)
      @cards = cards
      @pipe.puts cards.join $/
      @pipe.puts
    end
    
    def request_pass(to, direction)
      # Ask nicely
      @pipe.puts 'PL' if direction == :left
      @pipe.puts 'PR' if direction == :right
      @pipe.puts 'PA' if direction == :across
      @pipe.puts 'NP' if direction == :nopass
      @pipe.puts to
      @pipe.puts
      
      # Wait for input here
      c = [get_card,get_card,get_card]
            
      # Validate
      c.map! { |e| @cards.delete validate(e, nil, true) } unless direction == :nopass
      
      $logger.debug("Player #{@id} is passing #{c.join ' '} to player #{to}.")
      
      # Confirmation
      @pipe.puts c.join $/
      @pipe.puts ''
      
      c
    end
    
    def receive_pass(from, cards)
      # Imporant: the new cards should come first in the list
      @cards = cards + @cards unless from == @id
      
      @pipe.puts from
      @pipe.puts @cards.join $/
      @pipe.puts
    end
    
    def request_start
      @pipe.puts '0' # Round 0
      @pipe.puts @id # Started with self
      @pipe.puts '0' # Heart not broken
      @pipe.puts '0' # 0 cards follows
      @pipe.puts
      
      # Wait for input here (then ignore it)
      @pipe.gets      
      
      # Confirmation
      @pipe.puts 'C2' # Choice ignored
      @pipe.puts
      
      $logger.debug("Starting game, ignoring player's choice. Playing a C2.")
      
      # Remove card from hand
      @cards.delete Card.from_string('C2')
    end
    
    def request_play(trick_no, starter, trick_cards, heart_broken)
      @pipe.puts trick_no
      @pipe.puts starter
      @pipe.puts heart_broken ? '1' : '0'
      @pipe.puts trick_cards.count
      @pipe.puts trick_cards.join $/ unless trick_cards.empty?
      @pipe.puts
      
      # Wait for input here
      suite = trick_cards[0].nil? ? nil : trick_cards[0].suite
      
      c = get_card      
      c = validate(c, suite, heart_broken)
      
      # Confirmation
      @pipe.puts c
      @pipe.puts
      
      # Remove card from hand
      @cards.delete c
    end
    
    def round_summary(trick_no, starter, trick_cards, heart_broken, winner, points)
      @pipe.puts trick_no
      @pipe.puts starter
      @pipe.puts heart_broken ? '1' : '0'
      @pipe.puts trick_cards.join $/
      @pipe.puts winner
      @pipe.puts points
      @pipe.puts
    end
    
    def game_summary(points)
      @pipe.puts points.join $/
      @pipe.puts
    end
    
    def has?(card)
      card = Card.from_string(card) if card.is_a? String
      @cards.include? card
    end
    
    def kill!
      @pipe.close_write
      @pipe.close
    end
    
    private
    
    def get_card
      input = @pipe.gets.chomp!
      $logger.debug("get_card(): raw input is #{input}")
      Card.from_string(input)
    end
    
    def validate(card, suite, allows_hearts)
      $logger.debug("Validating #{card}: suite=#{suite}, allows_hearts=#{allows_hearts}.")
      
      r = card
      
      until has?(r) &&
            (suite.nil? || r.suite == suite || out_of?(suite)) &&
            (r.suite != 'H' || allows_hearts || (suite.nil? && all_hearts?) || out_of?(suite))
        r = @cards.randomly_pick(1)[0]
      end
      
      $logger.debug("Validation completed for #{card}: picked #{r}.")
            
      r
    end
    
    def out_of?(suite)
      return false if suite.nil?
      @cards.all? { |card| card.suite != suite } 
    end
    
    def all_hearts?
      @cards.all? { |card| card.suite == 'H' }
    end
  end
end