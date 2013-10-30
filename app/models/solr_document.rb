# -*- encoding : utf-8 -*-
class SolrDocument 
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  include Blacklight::Solr::Document

  # Adds Collection behaviors to the SolrDocument.
  include Hydra::Collections::SolrDocumentBehavior

  # Method to return the ActiveFedora model
  def hydra_model
    Array(self[Solrizer.solr_name('active_fedora_model', Solrizer::Descriptor.new(:string, :stored, :indexed))]).first
  end

  # Method to return the ActiveFedora model
  def accession_num
    Array(self[Solrizer.solr_name('accession_num', :stored_searchable)]).first
  end

  def accession_type
    Array(self[Solrizer.solr_name('accession_type', :stored_searchable)]).first
  end

  def file_size
    Array(self[Solrizer.solr_name('file_size', :stored_searchable)]).first
  end

  def file_type
    Array(self[Solrizer.solr_name('identification_identity_mime_type', :stored_searchable)]).first
  end

  def disk_num
    Array(self[Solrizer.solr_name('disk_num', :stored_searchable)]).first
  end

  def disk_label
    Array(self[Solrizer.solr_name('disk_label')]).first
  end

  # if available, show the relative path, otherwise just the filename (label)
  def relative_path
    Array(self[Solrizer.solr_name('relative_path', :stored_searchable)]).first || label 
  end

  def image_avail?
    avail = self[Solrizer.solr_name('image_avail', Sufia::GenericFile.noid_indexer)]
    avail.blank? ? false : (avail == 'true') ? true : false
  end

  # self.unique_key = 'id'
end
