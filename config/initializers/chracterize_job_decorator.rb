require 'active_fedora/solr_service'

Sufia::Jobs::CharacterizeJob.class_eval do
  alias_method :after_characterize_orig, :after_characterize
  def after_characterize
    after_characterize_orig
    unless generic_file.pdf? || generic_file.image? || generic_file.video?
      generic_file.create_derivatives
      generic_file.save
    end
  end
end


#ActiveFedora::Associations::HasAndBelongsToManyAssociation.class_eval do
#
#  def find_target
#    pids = @owner.ids_for_outbound(@reflection.options[:property])
#    return [] if pids.empty?
#    solr_result = []
#    0.step(pids.size,200) do |startIdx|
#      query = ActiveFedora::SolrService.construct_query_for_pids(pids.slice(startIdx,200))
#      result = ActiveFedora::SolrService.query(query, rows: 1000)
#      solr_result += result
#    end
#    return ActiveFedora::SolrService.reify_solr_results(solr_result,{load_from_solr:true})
#  end
#end
