class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydra::Collections::Collectible
  include Auditable
  include ArchivalDerivatives 
  include ActiveFedora::RelsInt
  include Hydra::Derivatives

  after_validation :save_infected_files_without_content

  # alias the collection in the generic File to accession since that is what it really is
  alias  :accessions :collections
  alias :accessions= :collections=

  def self.office_mime_types
    ['application/msword','application/vnd.ms-excel','application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation']
  end


  def terms_for_editing
    logger.warn "\n\n!!!!!! In terms #{terms_for_display}"
    terms_for_display - [:date_modified, :date_uploaded]
  end

  def terms_for_display
    super.map{|v| v.to_sym} - [:description]
  end

  def office?
    self.class.office_mime_types.include? self.mime_type
  end

  alias_method :orig_to_solr, :to_solr
  def to_solr(solr_doc={}, opts={})
    # since I may have been loaded via solr and I can not solorize if I have reify myself
    self.reify! if  self.inner_object.is_a? ActiveFedora::SolrDigitalObject
    solr_doc = orig_to_solr(solr_doc, opts)
    solr_doc = index_collection_pids(solr_doc)
    solr_doc[Solrizer.solr_name('file_size', :stored_searchable)]  = file_size
    return solr_doc
  end


  def save_infected_files_without_content
    if Array(errors.get(:content)).any? { |msg| msg =~ /A virus was found/ }
      content.content = errors.get(:content)
      save!
    end
  end
end
