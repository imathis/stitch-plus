require 'digest/md5'
require 'stitch-rb'
require 'colorator'

class StitchPlus

  def initialize(options)
    @options = {
      :dependencies   => [],
      :output         => 'all.js',
      :fingerprint    => false,
      :paths          => nil,
      :cleanup        => true,
      :all_on_start   => false,
      :run_all        => nil,
      :uglify         => false
    }.merge(options)

    begin
      require 'coffee-script'
      @has_coffee = true
    rescue LoadError
    end

    if @options[:uglify]
      begin
        require 'uglifier'
        @uglifier = Uglifier.new
      rescue LoadError
      end
    end
      
  end

  def compile

    @files ||= all_files

    if @files.join().match(/\.coffee/) and !@has_coffee
      error "Cannot compile coffeescript".red
      error "Add ".white + "gem 'coffee-script'".yellow + " to your Gemfile."
    end

    if @options[:uglify] and !@uglifier
      error "Cannot uglify javascript".red
      error "Add ".white + "gem 'uglifier'".yellow + " to your Gemfile."
    end

    @fingerprint = script_fingerprint
    @file = output_file(@fingerprint)

    if has_fingerprint(@file)
      info "Stitch " + "identical ".green + @file
      true
    else
      begin
        write_msg = (File.exists?(@file) ? "overwrite " : "created ").yellow + @file
        cleanup(@file) if @options[:cleanup]

        js = Stitch::Package.new(:dependencies => dependencies, :paths => @options[:paths]).compile
        js = @uglifier.compile(js) if @uglifier
        js = "/* Build fingerprint: #{@fingerprint} */\n" + js

        File.open(@file, 'w') { |f| f.write js }

        info "Stitch " + write_msg
        true
      rescue StandardError => e
        error "Stitch " + "failed ".red + "to write #{@file}"
        error e
        false
      end
    end
  end

  def dependencies
    deps = [] << @options[:dependencies]
    deps.flatten.collect { |item| 
      item = File.join(item,'**/*') if File.directory?(item)
      Dir.glob item
    }.flatten.uniq.collect { |item|
      File.directory?(item) ? nil : item 
    }.compact
  end

  def output_file(fingerprint = nil)
    fingerprint ||= script_fingerprint
    file = @options[:output]
    if @options[:fingerprint]
      basename = File.basename(file).split(/(\..+)$/).join("-#{fingerprint}")
      dir = File.dirname(file)
      file = File.join(dir, basename)
    end
    file
  end
  
  # Get a list of all files to be stitched
  def all_files
    files = []
    files << dependencies if @options[:dependencies]
    files << Dir.glob(File.join(@options[:paths], '**/*')) if @options[:paths]
    files.flatten.uniq
  end

  # Get and MD5 hash of files including order of dependencies
  def script_fingerprint
    @files ||= all_files
    Digest::MD5.hexdigest(@files.map! { |path| "#{File.mtime(path).to_i}" }.join + @options.to_s)
  end

  # Determine if the file has a fingerprint
  def has_fingerprint(file)
    File.size?(file) && File.open(file) {|f| f.readline} =~ /#{@fingerprint}/
  end

  def cleanup(file)
    match = File.basename(@options[:output]).split(/(\..+)$/).map { |i| i.gsub(/\./, '\.')}
    Dir.glob(File.join(File.dirname(@options[:output]), '**/*')).each do |item|
      if File.basename(item) != File.basename(file) and File.basename(item).match /^#{match[0]}(-.+)?#{match[1]}/i
        info "Stitch " + "deleted ".red + item
        FileUtils.rm(item) 
      end
    end
  end

  private

  def info(message)
    if defined?(Guard::UI)
      Guard::UI.info message
    else
      puts message
    end
  end

  def error(message)
    if defined?(Guard::UI)
      Guard::UI.error message
    else
      puts message
    end
  end


end

