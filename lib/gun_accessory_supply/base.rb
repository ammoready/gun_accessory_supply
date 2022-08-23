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
        begin
          yield(sftp)
        end
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

    def get_file(filename, file_directory=nil)
      connect(@options) do |sftp|
        begin
          tempfile = Tempfile.new

          sftp.download!(File.join(file_directory, filename), tempfile.path)

          return tempfile
        end
      end
    end

    def get_most_recent_file(file_prefix, file_directory=nil)
      filenames = []

      connect(@options) do |sftp|
        sftp.dir.foreach(file_directory) { |entry| filenames << entry.name }
        filename = filenames.select{ |n| n.include?(file_prefix) }.sort.last

        tempfile = self.get_file(filename, file_directory)
        return tempfile
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
