class IngestLocalJob

  def queue_name
    :ingest
  end

  attr_accessor :directory, :file_list, :user_key, :accession_id

  def initialize( directory, file_list, user_key, accession_id)
    self.directory = directory
    self.file_list = file_list
    self.user_key = user_key
    self.accession_id = accession_id
  end

  def run
    @accession = Accession.find( accession_id)
    @error_files = []

    has_directories = false
    files = []
    file_list.each do |filename|
      if File.directory?(File.join(directory, filename))
        has_directories = true
        Dir[File.join(directory, filename, '**', '*')].each do |single|
          next if File.directory? single
          logger.info("Ingesting file: #{single}")
          files << single.sub(directory + '/', '')
          logger.info("after removing the user directory #{directory} we have: #{files.last}")
        end
      else
        files << filename
      end
    end
    files.each do |filename|
      ingest_one(filename, has_directories)
    end

    # save all the new members to the accession
    @accession.save

    #notify the user

    job_user = User.batchuser()
    good_files = files.size-@error_files.size
    message = '<span class="accessionid ui-helper-hidden">ss-'+accession_id+"</span>#{good_files} #{"file".pluralize(good_files)} were uploaded from location#{file_list.size > 1 ?'s':''}: #{file_list.join(", ")}"
    if @error_files.size > 0
      @error_files.each do |error|
        message+="<div class='row error'>Error for file #{error[:filename]}: #{error[:error]}</div>"
      end
    end
    job_user.send_message(current_user, message, 'Local File Ingest Complete')

  end

  def current_user
    @current_user ||= User.find_by_user_key(user_key)
  end

  def ingest_one(filename, unarranged)
    # do not remove ::
    generic_file = ::GenericFile.new
    basename = File.basename(filename)
    generic_file.label = basename
    generic_file.relative_path = filename if filename != basename
    Sufia::GenericFile::Actions.create_metadata(generic_file, current_user, accession_id)
    @accession.members << generic_file
    job = IngestLocalFileJob.new(generic_file.id, directory, filename, user_key)
    begin
      job.run
    rescue => e
      @error_files << {filename:filename,error:e.message}
      logger.error "An exception occurred while processing one of the ingested files (#{filename}): #{e.inspect}"
    end
  end

end