module GunAccessorySupply
  class Base

    def self.connect(options = {})
      requires!(options, :username, :password)

      Net::SFTP.start(
        GunAccessorySupply.config.proxy_host || GunAccessorySupply.config.sftp_host,
        options[:username],
        password: options[:password],
        port: GunAccessorySupply.config.proxy_port || GunAccessorySupply.config.sftp_port
      ) do |sftp|
        yield(sftp)
      end
    end

    protected

    # Wrapper to `self.requires!` that can be used as an instance method.
    def requires!(*args)
      self.class.requires!(*args)
    end

    def self.requires!(hash, *params)
      params.each do |param|
        if param.is_a?(Array)
          raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

          valid_options = param[1..-1]
          raise ArgumentError.new("Parameter: #{param.first} must be one of: #{valid_options.join(', ')}") unless valid_options.include?(hash[param.first])
        else
          raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
        end
      end
    end

    # Instance methods become class methods through inheritance
    def connect(options)
      self.class.connect(options) do |sftp|
        yield(sftp)
      end
    end

    def content_for(xml_doc, field)
      node = xml_doc.css(field).first

      if node.nil?
        nil
      else
        node.content.try(:strip)
      end
    end

    def get_file(filename, file_directory = nil)
      connect(@options) do |sftp|
        tempfile = Tempfile.new

        sftp.download!(File.join(file_directory, filename), tempfile.path)

        return tempfile
      end
    end

    def get_full_filenames(filename_regexes = [], file_directory = nil)
      connect(@options) do |sftp|
        filenames = sftp.dir.entries(file_directory).map(&:name)
        full_regex = Regexp.union(*filename_regexes)

        return filenames.select { |filename| filename =~ full_regex }
      end
    end

    def get_most_recent_file(file_prefix, file_directory = nil)
      connect(@options) do |sftp|
        filename = sftp.
          dir.
          entries(file_directory).
          map(&:name).
          select { |filename| filename.include?(file_prefix) }.
          sort.
          last

        return get_file(filename, file_directory)
      end
    end

    def parse_row(row)
      row.gsub('"','').gsub("\r\n", '').encode('UTF-8', invalid: :replace).split(",")
    end

    def write_file(path, data)
      connect(@options) do |sftp|
        begin
          sftp.file.open(path, "w") do |f|
            f.puts data
          end
        end
      end
    end

  end
end
