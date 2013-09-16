class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydra::Collections::Collectible
  include Auditable
  include ArchivalDerivatives 
  include ActiveFedora::RelsInt
  include Hydra::Derivatives


  # alias the collection in the generic File to accession since that is what it really is
  alias  :accessions :collections
  alias :accessions= :collections=

  def self.office_mime_types
    ['application/msword','application/vnd.ms-excel','application/vnd.ms-powerpoint']
  end


  def terms_for_editing
    logger.warn "\n\n!!!!!! In terms #{terms_for_display}"
    terms_for_display - [:date_modified, :date_uploaded]
  end

  def terms_for_display
    super.map{|v| v.to_sym}
  end

  def office?
    self.class.office_mime_types.include? self.mime_type
  end


end
