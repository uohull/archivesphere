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
    Array(self[Solrizer.solr_name('fields_accession_num', :stored_searchable)]).first
  end

  def disk_num
    Array(self[Solrizer.solr_name('fields_disk_num', :stored_searchable)]).first
  end


  # self.unique_key = 'id'
  
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )
end
