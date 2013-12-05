class AccessionPresenter < Presenter

  attr_accessor :tree

  def initialize(accession, params)
    super params
    @accession = accession
  end

  def crumbs( action)
    crumbs = super(action)

    crumbs << (@accession.collections[0].blank? ?  link_to("Unassigned Ingests", Rails.application.routes.url_helpers.unassigned_collection_path) : link_to(@accession.collections[0].title, Hydra::Collections::Engine.routes.url_helpers.collection_path(@accession.collections[0])))

    crumbs << (action == "show" ? @accession.accession_num : link_to("show #{@accession.accession_num}",Rails.application.routes.url_helpers.accession_path(@accession.noid))) unless @accession.noid.blank?

    crumbs
  end

  def print_tree( view)
    @html = ""
    @html = print_tree_internal(view, tree, '')  unless tree.blank?
    @html
  end

  protected

  def print_tree_internal(view, node, parent_node, id_list=[])
    node.each_pair do |path, subtree|
      id= orig_id = File.basename(path)#.tr(" ", "_")
      doc = subtree[:member]
      i=0
      while id_list.include?(id)
        i+=1
        id=orig_id+"_"+i.to_s
      end
      id_list << id
      @html += "\n"
      content =  view.render partial:'/accessions/path', locals: {path: File.basename(path)}
      unless subtree[:member].blank?
        content = view.render partial:'/accessions/file', locals: {path: File.basename(path), id:subtree[:member].noid, document:doc}
      end
      if parent_node != ''
        tag_content = content_tag(:tr, content_tag(:td, content), {"data-tt-parent-id" => parent_node, "data-tt-id" => id} )
      else
        tag_content = content_tag(:tr, content_tag(:td, content), {"data-tt-id" => id} )
      end
      @html += tag_content
      print_tree_internal(subtree, id, id_list) unless subtree.empty?  || subtree[:member]
    end

    @html
  end

end