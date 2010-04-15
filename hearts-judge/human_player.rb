require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'

module Hearts
  class HumanPlayer < Player    
    def initialize(id, game)
      $logger.info("Player #{id} is a human")
      
      $stdout.print "Player #{id}, what's your name? "
      $stdout.flush
      name = $stdin.gets.chomp!
      
      $logger.debug("Player #{id} responded with #{name}")
      
      if name.empty?
        name = "Unnamed human player"
      end
      
      $stdout.puts "Welcome, #{name}"
      
      # Call parent initializer
      super(id,name,game)
    end
    
    # Receive the hand from the judge
    def deal_cards(cards)
      super
      @cards.sort!
      show_hand
    end
    
    # Pick three cards to pass
    def request_pass(player,direction)
      unless player == self
        show_hand
        $stdout.puts "#{self}, please pass THREE cards to your #{direction} (#{player}):"
        input = [get_card,get_card,get_card]
        
        input.map! { |c| @cards.delete validate(nil,c) }
        
        $logger.debug("#{self} is passing #{input.join ' '} to #{player}")
        $stdout.puts "#{self} is passing #{input.join ' '} to his #{direction} (#{player})."
        $stdin.gets
        input
      end
    end
    
    # Receive the cards passed on to you 
    def receive_pass(player,cards)
      unless player == self
        super
        @cards.sort!
        $stdout.puts "#{self}, you received #{cards[0...3].join ' '} from #{player}."
        show_hand
        $stdin.gets
      end
    end
    
    # Start the game with a C2
    def request_start(trick)
      $stdout.puts "#{self}, you will start the game by playing a C2." 
      $stdin.gets
      super
    end
    
    # Pick a card to play
    def request_play(trick)
      $stdout.puts "Round #{trick.number} started by #{trick.starter}, current trick is #{trick.cards.join ' '}."
      $stdout.puts @game.heart_broken? ? "The heart has already been broken." : "The heart has yet to be broken."
      show_hand
      $stdout.puts "#{self}, please play a card:"
      card = validate(trick,get_card)
      $stdout.puts "#{self} is playing a #{card}."
      $stdin.gets
      
      play(trick,card,false)
    end
    
    def trick_summary(trick)
      $stdout.puts "Round #{trick.number} started with player #{trick.starter}, the trick is #{trick.cards.join ' '}."
      $stdout.puts @game.heart_broken? ? "The heart has already been broken." : "The heart has yet to be broken."
      $stdout.puts "#{trick.winner} won this trick, gained #{trick.points} points."
      $stdin.gets
    end
    
    def game_ended
      $stdout.puts "#{self}, you scored #{@game.points[@id]} points in this game."
    end
    
    protected
    
    def validate(trick,card)
      temp = super
      
      if temp != card
        puts "#{@name}, your choice of #{card} is not valid. Picking #{temp} for you instead."
      end
      
      temp
    end
    
    private
    
    def get_card
      Card.from_string($stdin.gets.chomp!)
    end
    
    def show_hand
      puts "#{self}, this is your hand:"
      puts @cards.join ' '
    end
  end
end