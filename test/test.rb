require '../lib/stitch-plus'


s = StitchPlus.new({config: 'stitch.yml'})

puts "Javascripts to be compiled:"
puts s.all_files.map { |f| "  #{f}"}

s.write
