require '../lib/stitch-plus'

s = StitchPlus.new({dependencies: ['javascripts/dependencies'], paths: 'javascripts/modules'})

puts "Javascripts to be compiled:"
puts s.all_files.map { |f| "  #{f}"}

s.compile
