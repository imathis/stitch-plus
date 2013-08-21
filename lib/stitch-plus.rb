require 'digest/md5'
require 'stitch-rb'
require 'colorator'
require 'yaml'

class StitchPlus
  attr_accessor :options, :deleted

  def initialize(options={})

    @options = {
      :dependencies   => nil,
      :paths          => nil,
      :output         => 'all.js',
      :fingerprint    => false,
      :cleanup        => true,
      :uglify         => false,
      :uglify_options => {},
      :config         => nil
    }
    @deleted = []

    set_options(options)

    begin
      require 'coffee-script'
      @has_coffee = true
    rescue LoadError
    end

  end

  # Set or temporarily set options
  def set_options(options={}, temporary=false)
    @old_options = @options if temporary

    # If options is a file path, read options from yaml
    options = { :config => options } if options.class == String
    options = load_options(options)

    @options = @options.merge symbolize_keys(options)

    if @options[:uglify]
      begin
        require 'uglifier'
        @uglifier = Uglifier.new(@options[:uglify_options])
      rescue LoadError
      end
    end

  end

  def temp_options(options)
    set_options(options, true)
  end

  # Compile javascripts, uglifying if necessary
  def compile

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
      error "Stitch failed to compile".red
      error e
      false
    end
  end

  # Write compiled javascripts to disk
  def write(options=nil)
    temp_options(options) if options

    @fingerprint = file_fingerprint
    @file = output_file

    js = "/* Build fingerprint: #{@fingerprint} */\n" + compile

    if has_fingerprint(@file, @fingerprint)
      info "Stitch " + "identical ".green + @file.sub(Dir.pwd, '')
      reset_options if options
      true
    else
      begin
        write_msg = (File.exists?(@file) ? "overwrite " : "created ").yellow + @file.sub(Dir.pwd, '')
        cleanup(@file) if @options[:cleanup]

        File.open(@file, 'w') { |f| f.write js }

        info "Stitch " + write_msg
        true
      rescue StandardError => e
        error "Stitch failed to write #{@file.sub(Dir.pwd, '')}".red
        error e
        reset_options if options
        false
      end
    end

  end

  # return the compiled js path including fingerprint if enabled
  def output_file(options=nil)
    temp_options(options) if options
    file = @options[:output]

    if @options[:fingerprint]
      @fingerprint ||= file_fingerprint
      basename = File.basename(file).split(/(\..+)$/).join("-#{@fingerprint}")
      dir = File.dirname(file)
      file = File.join(dir, basename)
    end

    reset_options if options
    file
  end

  # Return the path for the last file written
  # This exists because it's more performant than calling output_file unnecessarily
  #
  def last_write
    @file
  end

  # Get a list of all files to be stitched
  def all_files(options=nil)
    temp_options(options) if options
    files = []
    files << dependencies if @options[:dependencies]
    files << Dir.glob(File.join(@options[:paths], '**/*')) if @options[:paths]
    reset_options if options
    files.flatten.uniq
  end

  # Get and MD5 hash of files including order of dependencies
  def file_fingerprint(options=nil)
    temp_options(options) if options
    fingerprint = Digest::MD5.hexdigest(all_files.map! { |path| "#{File.mtime(path).to_i}" }.join + @options.to_s)
    reset_options if options
    fingerprint
  end

  private
  
  # Remove existing generated files with the same options[:output] name
  def cleanup(file)
    Dir.glob(@options[:output].sub(/\./, '*')).each do |item|
      if File.basename(item) != File.basename(file)
        info "Stitch " + "deleted ".red + item
        FileUtils.rm(item)
        @deleted << item.sub(Dir.pwd, '')
      end
    end
  end


  # Determine if the file has a fingerprint
  def has_fingerprint(file, fingerprint)
    File.size?(file) && File.open(file) {|f| f.readline} =~ /#{fingerprint}/
  end

  # Return all files included as dependencies, globbing as necessary
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

  def reset_options
    if @old_options
      @options = @old_options
      @old_options = nil
    end
  end

  def load_options(options)
    if options[:config] and File.exist? options[:config]
      config = YAML::load(File.open(options[:config]))
      config = config['stitch'] unless config['stitch'].nil?
      options = options.merge config
    end
    options
  end

  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
    new_value = case value
                when Hash then symbolize_keys(value)
                else value
                end
    result[new_key] = new_value
    result
    }
  end

end

