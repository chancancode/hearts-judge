#!/usr/bin/ruby

# Judge script

# TODO:
#   feature: implement time limit

require 'logger'
require 'optparse'
require 'constants.rb'
require 'game.rb'
require 'trick.rb'
require 'card.rb'
require 'player.rb'
require 'human_player.rb'
require 'npc_player.rb'
require 'array_extension.rb'
# require 'rubygems'
# require 'ruby-debug'

# Turn off Ruby warnings
$VERBOSE = nil

module Hearts
  class Judge
    
    def initialize  
      # Parse arguments
      # 
      # For player commands...
      # 
      # Java: ruby judge.rb "java -classpath ../java-example/ Player"
      # Ruby: ruby judge.rb "ruby ../ruby-example/dummy.rb"
      # 
      # To supress STDERR of player programs, add "2> /dev/null" to the end of the
      # command, i.e. ruby judge.rb "ruby ../ruby-example/dummy.rb 2> /dev/null"

      options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: ruby judge.rb [options] command0 command1 ..."
  
        options[:shuffle] = false
        opts.on("-s", "--shuffle", "Shuffle the players' positions") do
          options[:shuffle] = true
        end
  
        options[:verbose] = false
        opts.on("-v", "--verbose", "Verbose mode") do
          options[:verbose] = true
        end
  
        opts.on("-h", "--help", "Display this message") do
          puts opts
          exit
        end
      end.parse!

      raise ArgumentError, "Too many players!" if ARGV.count > 4
      
      # Initialize logger (global variable)
      $logger = Logger.new(STDERR)
      $logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      $logger.debug('Created logger.')
      $logger.debug("shuffle=#{options[:shuffle]}")
      $logger.debug("verbose=#{options[:verbose]}")

      # Store the commands
      @commands = ARGV + [nil,nil,nil,nil] # Add some padding...
      @commands = @commands[0..3] # Then trim it.
      @commands.shuffle! if options[:shuffle]
      
      @games_played = 0
      @current_game = nil
      @points = [0,0,0,0]
    end
    
    def next_game!
      $logger.info('*** Starting new game ***')
      
      @current_game = Game.new
            
      @commands.each_with_index do |cmd,i|
        @current_game << (cmd ? NPCPlayer.new(i,@current_game,cmd) : HumanPlayer.new(i,@current_game))
      end
      
      $logger.info('All players are ready.')
    end
    
    def deal_cards
      $logger.info('Dealing cards...')
      
      $logger.debug('Shuffling deck.')
      deck = Card.deck.shuffle!
      
      @current_game.players.each do |player|
        $logger.debug("Dealing cards to #{player}")
        player.deal_cards(deck.slice!(0,13))
      end
    end
    
    def pass_cards
      $logger.info('Passing cards...')

      direction = case @games_played % 4
        when 0 then :left
        when 1 then :right
        when 2 then :across
        when 3 then :nopass
      end
      
      cards = []
            
      @current_game.players.each_with_index do |player,i|
        neighbour = player.neighbour(direction)
        $logger.debug("#{player} is picking cards for #{neighbour}...")
        cards[i] = player.request_pass(neighbour,direction)
      end
      
      @current_game.players.each_with_index do |player,i|
        neighbour = player.neighbour(direction)
        $logger.debug("#{player} is passing cards to #{neighbour}...")
        neighbour.receive_pass(player,cards[i])
      end
      
      $logger.debug("Done passing cards.")
    end
    
    def game_on
      $logger.info("Game on!")
      
      @current_game.start!
      
      13.times do
        trick = @current_game.current_trick
        
        4.times do
          player = trick.current_player
                    
          if @current_game.new? && trick.empty?
            player.request_start(trick)
          else
            player.request_play(trick)
          end
          
          trick.next_player!
        end
        
        $logger.info("Player #{trick.winner} won the trick, gained #{trick.points} points.")
        @current_game.next_trick!
      end
    end
   
    def clean_up
      game_points = @current_game.points
      
      @current_game.players.each_with_index do |player,i|
        @points[i] += game_points[i]
        $logger.info("#{player} scored #{game_points[i]} points in this game, accumulated a total of #{@points[i]}.")
        player.game_ended # callback
      end
      
      sleep 30
      
      @current_game.players.each do |player|
        $logger.debug("Killing #{player}")
        player.kill!
      end
    end
  end
end

j = Hearts::Judge.new
j.next_game!
j.deal_cards
j.pass_cards
j.game_on
j.clean_up