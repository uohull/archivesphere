class IngestLocalJob

  include ActionView::Helpers::UrlHelper

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
    message = '<span class="accessionid ui-helper-hidden">ss-'+accession_id+"</span>#{good_files} #{"file".pluralize(good_files)} were uploaded from location #{file_list.size > 1 ?'s':''}: #{file_list.join(", ")}. &nbsp;"
    message += link_to("Go to Ingest ##{@accession.accession_num}",Rails.application.routes.url_helpers.accession_path(accession_id))
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
    path = File.join(directory, filename)
    generic_file.add_file(File.open(path), 'content', generic_file.label)

    generic_file.collections << @accession
    Sufia::GenericFile::Actions.create_metadata(generic_file, current_user, nil)
    generic_file.record_version_committer(current_user)
    Sufia.queue.push(ContentDepositEventJob.new(generic_file.pid, user_key))

    # need to add to the accession and save the accession later since the addition of the accession is happening before the first save of the file
    # when the gf does not have a pid as the association is created the reciprocal relation is not created
    @accession.members <<  generic_file
  rescue => e
    @error_files << {filename:filename,error:e.message}
    logger.error "An exception occurred while processing one of the ingested files (#{filename}): #{e.inspect}"
  end

end
