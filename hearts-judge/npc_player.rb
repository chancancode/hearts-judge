require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'

module Hearts
  class NPCPlayer < Player    
    def initialize(id, game, command)
      $logger.info("Player #{id}='#{command}'")
      
      $logger.debug("Launching '#{command}'")
      @pipe = IO.popen(command, 'r+')
      
      $logger.debug("Waiting for player #{id} to get ready...")
      name = @pipe.gets.chomp!
      
      $logger.debug("Player #{id} responded with #{name}")
      
      if name == 'READY' || name.empty?
        name = "Unnamed #{command.split[0]} player"
      end
      
      $logger.debug("Player #{id} is ready")
      
      # Send player ID
      @pipe.puts id
      @pipe.flush
      
      # Call parent initializer
      super(id,name,game)
    end
    
    # Receive the hand from the judge
    def deal_cards(cards)
      super
      @pipe.puts cards.join $/
      @pipe.puts
      @pipe.flush
    end
    
    # Pick three cards to pass
    def request_pass(player,direction)
      # Ask nicely
      @pipe.puts 'PL' if direction == :left
      @pipe.puts 'PR' if direction == :right
      @pipe.puts 'PA' if direction == :across
      @pipe.puts 'NP' if direction == :nopass
      @pipe.puts player.id
      @pipe.puts
      
      # Wait for input here
      input = [get_card,get_card,get_card]
      
      if direction == :nopass
        @pipe.puts 'JUNK'
        @pipe.puts 'JUNK'
        @pipe.puts 'JUNK'
        @pipe.puts
        @pipe.flush
      else
        # Validate and remove from hand
        input.map! { |c| @cards.delete validate(nil,c) }
        
        $logger.debug("#{self} is passing #{input.join ' '} to #{player}")
        
        # Confirmation
        @pipe.puts input.join $/
        @pipe.puts
        @pipe.flush
      end
      
      input
    end
    
    # Receive the cards passed on to you 
    def receive_pass(player,cards)
      super
      @pipe.puts player.id
      @pipe.puts @cards.join $/
      @pipe.puts
      @pipe.flush
    end
    
    # Start the game with a C2
    def request_start(trick)
      @pipe.puts '0' # Round 0
      @pipe.puts @id # Started with self
      @pipe.puts '0' # Heart not broken
      @pipe.puts '0' # 0 cards follows
      @pipe.puts
      @pipe.flush
      
      # Wait for input here (then ignore it)
      input = @pipe.gets.chomp!
      
      # Confirmation
      $logger.debug("Ignoring player's choice '#{input}'")
      @pipe.puts 'C2'
      @pipe.puts
      @pipe.flush
      
      super
    end
    
    # Pick a card to play
    def request_play(trick)
      @pipe.puts trick.number
      @pipe.puts trick.starter.id
      @pipe.puts @game.heart_broken? ? '1' : '0'
      @pipe.puts trick.count
      @pipe.puts trick.cards.join $/ unless trick.empty?
      @pipe.puts
      @pipe.flush
      
      # Wait for input here      
      card = validate(trick,get_card)
      
      # Confirmation
      @pipe.puts card
      @pipe.puts
      @pipe.flush
      
      play(trick,card,false)
    end
    
    def trick_summary(trick)
      @pipe.puts trick.number
      @pipe.puts trick.starter.id
      @pipe.puts @game.heart_broken? ? '1' : '0'
      @pipe.puts trick.cards.join $/
      @pipe.puts trick.winner.id
      @pipe.puts trick.points
      @pipe.puts
      @pipe.flush
    end
    
    def game_ended
      @pipe.puts @game.points.join $/
      @pipe.puts
      @pipe.close_write
    end
    
    # Clean up
    def kill!
      @pipe.close
    end
    
    private
    
    def get_card
      $logger.debug("#{self} is waiting for input...")
      input = @pipe.gets.chomp!
      $logger.debug("#{self}: raw input is '#{input}'")
      Card.from_string(input)
    end
  end
end