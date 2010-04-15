def filter(line)
  return if line.nil?
  return line if line.include?('Press enter')
  return line if line[0...1] != 'D' && line[0...1] != 'I'
  
  return nil unless line.include?('INFO') || line.include?('invalid') || line.include?('cards') || line.include?('passing')
  
  return nil if line.match /Player [0-3]=/
  return nil if line.include?('joined the game')
  return nil if line.include?('All players are ready')
  return nil if line.include?('Dealing cards')
  return nil if line.include?('Passing cards...')
  return nil if line.include?('is passing cards to')
  return nil if line.include?('Done passing cards.')
  return nil if line.include?('Game on!')
  return nil if line.include?('took')
  
  return line.split(':')[3..-1].join(':')
end

while true
  line = filter(gets.chomp!)
  puts line unless line.nil?
end