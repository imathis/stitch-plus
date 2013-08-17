require '../lib/stitch-plus'


s = StitchPlus.new('stitch.yml')

puts "Javascripts to be compiled:"
puts s.all_files.map { |f| "  #{f}"}

puts s.compile
