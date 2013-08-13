require '../lib/stitch-plus'

options = {
  dependencies: ['javascripts/dependencies'],
  paths: ['javascripts/modules'],
  write: 'javascripts/app.js',
  fingerprint: true
}

s = StitchPlus.new(options)

puts "Javascripts to be compiled:"
puts s.all_files.map { |f| "  #{f}"}

s.compile
