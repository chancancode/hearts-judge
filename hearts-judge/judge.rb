#!/usr/bin/ruby

# Judge script

# TODO:
#   refractor: put this in a proper class
#   refractor: move non-core functionalities them into other files
#   feature: implement time limit
#   feature: enforce "no points in first round" rule

require 'logger'
require 'optparse'
require 'card.rb'
require 'human_player.rb'
require 'npc_player.rb'
require 'array_extension.rb'

# Turn off Ruby warnings
$VERBOSE = nil

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

# Initialize logger
$logger = Logger.new(STDERR)
$logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
$logger.debug('Created logger.')
$logger.debug("shuffle=#{options[:shuffle]}")
$logger.debug("verbose=#{options[:verbose]}")

# Initialize players
players = []
commands = ARGV + [nil,nil,nil,nil] # Pad...
commands = commands[0..3] # Then chop

commands.shuffle! if options[:shuffle]

commands.each_with_index do |cmd,i|
  players[i] = cmd ? Hearts::NPCPlayer.new(i,cmd) : Hearts::HumanPlayer.new(i)
end

$logger.info('All players are ready.')



# Populate and shuffle the deck
# TODO: put this in the Card class?
$logger.debug('Shuffling deck.')
deck = Hearts::Card.deck.shuffle!



# Start the game 
$logger.info('Dealing cards...')

players.each do |player|
  $logger.debug("Dealing cards to player #{player.id}")
  player.deal_cards(deck.slice!(0,13))
end


$logger.info('Passing cards...')

$logger.debug('Picking cards to pass...')

passed_cards = []

players.each_with_index do |player,i|
  $logger.debug("Player #{player.id} is picking cards for player #{(i+1)%4} on his left...")
  passed_cards[(i+1)%4] = player.request_pass((i+1)%4, :left)
end

starter = -1
heart_broken = false

$logger.debug('Picking cards to pass...')

players.each_with_index do |player,i|
  $logger.debug("Player #{player.id} is getting his cards from player #{(i-1)%4}...")
  player.receive_pass((i-1)%4, passed_cards[i])
  starter = i if player.has? 'C2'
end

$logger.debug("Done passing cards.")

$logger.info("Game on!")

player_points = [0,0,0,0]

0.upto 12 do |i|
  $logger.info("Round #{i}:")
  
  $logger.info("Player #{starter} is starting the round.")
  
  trick_suite = nil
  trick = []
  comp_values = [0,0,0,0]
  points = 0
  
  0.upto 3 do |j|
    if i == 0 && j == 0
      c = players[starter].request_start
    else
      c = players[(starter+j)%4].request_play(i,starter,trick,heart_broken)
    end
    
    $logger.info("Player #{(starter+j)%4} played a #{c}.")
    
    heart_broken = true if c.suite == 'H'
    trick_suite = c.suite if j == 0
    trick << c
    comp_values[(starter+j)%4] = c.score if c.suite == trick_suite
    points += 13 if c.suite == 'S' && c.rank == 12
    points += 1 if c.suite == 'H'
  end
  
  $logger.debug("comp_values=#{comp_values.inspect}")
  
  winner = comp_values.index(comp_values.max)
  player_points[winner] += points
  
  $logger.info("Player #{winner} won the trick, gained #{points} points.")
  
  players.each do |player|
    player.round_summary(i, starter, trick, heart_broken, winner, points)
  end
  
  starter = winner
end

if player_points.max == 26
  $logger.info("Someone shot the moon!")
  player_points.map! { |e| 26-e }
end

players.each_with_index do |player,i|
  player.game_summary(player_points)
  $logger.info("Player #{i} scored #{player_points[i]} points in this game.")
end

players.each do |player|
  $logger.debug("Killing player #{player.id}")
  player.kill!
end