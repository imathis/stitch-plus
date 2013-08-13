require 'digest/md5'
require 'stitch-rb'
require 'colorator'

class StitchPlus

  def initialize(options)
    @options = {
      :dependencies   => nil,
      :paths          => nil,
      :write          => 'all.js',
      :fingerprint    => false,
      :cleanup        => true,
      :uglify         => false,
      :uglify_options => {}
    }
    
    set_options(options, false)

    begin
      require 'coffee-script'
      @has_coffee = true
    rescue LoadError
    end

  end

  def set_options(options={}, reset=true)
    @old_options = @options if reset
    @options = @options.merge(options)

    if @options[:uglify]
      begin
        require 'uglifier'
        @uglifier = Uglifier.new(@options[:uglify_options])
      rescue LoadError
      end
    end

    @options
  end

  def reset_options
    if @old_options
      @options = @old_options
      @old_options = nil
    end
  end

  def compile(options=nil)
    set_options(options) if options
    @options[:write] ? write : build
    reset_options if options
  end

  def build

    if all_files.join().match(/\.coffee/) and !@has_coffee
      error "Cannot compile coffeescript".red
      error "Add ".white + "gem 'coffee-script'".yellow + " to your Gemfile."
    end

    if @options[:uglify] and !@uglifier
      error "Cannot uglify javascript".red
      error "Add ".white + "gem 'uglifier'".yellow + " to your Gemfile."
    end

    begin
      js = Stitch::Package.new(:dependencies => dependencies, :paths => @options[:paths]).compile
      js = @uglifier.compile(js) if @uglifier
      js
    rescue StandardError => e
      error "Stitch failed to build".red
      error e
      false
    end
  end

  def write

    @fingerprint = script_fingerprint
    @file = output_file

    js = "/* Build fingerprint: #{@fingerprint} */\n" + build

    if has_fingerprint(@file, @fingerprint)
      info "Stitch " + "identical ".green + @file
      true
    else
      begin
        write_msg = (File.exists?(@file) ? "overwrite " : "created ").yellow + @file
        cleanup(@file) if @options[:cleanup]

        File.open(@file, 'w') { |f| f.write js }

        info "Stitch " + write_msg
        true
      rescue StandardError => e
        error "Stitch failed to write #{@file}".red
        error e
        false
      end
    end

  end

  def dependencies
    if @options[:dependencies]
      deps = [] << @options[:dependencies]
      deps.flatten.collect { |item| 
        item = File.join(item,'**/*') if File.directory?(item)
        Dir.glob item
      }.flatten.uniq.collect { |item|
        File.directory?(item) ? nil : item 
      }.compact
    else
      false
    end
  end

  def output_file(options=nil)
    set_options(options) if options
    file = @options[:write]

    if @options[:fingerprint]
      @fingerprint ||= script_fingerprint
      basename = File.basename(file).split(/(\..+)$/).join("-#{@fingerprint}")
      dir = File.dirname(file)
      file = File.join(dir, basename)
    end

    reset_options if options
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
    Digest::MD5.hexdigest(all_files.map! { |path| "#{File.mtime(path).to_i}" }.join + @options.to_s)
  end

  # Determine if the file has a fingerprint
  def has_fingerprint(file, fingerprint)
    File.size?(file) && File.open(file) {|f| f.readline} =~ /#{fingerprint}/
  end

  def cleanup(file)
    match = File.basename(@options[:write]).split(/(\..+)$/).map { |i| i.gsub(/\./, '\.')}
    Dir.glob(File.join(File.dirname(@options[:write]), '**/*')).each do |item|
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

