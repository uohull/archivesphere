module ApplicationHelper
  def print_tree(node, parent_node, id_list=[])
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
      content =  render partial:'accessions/path', locals: {path: File.basename(path)}
      unless subtree[:member].blank?
      content = render partial:'accessions/file', locals: {path: File.basename(path), id:subtree[:member].noid, document:doc}
      end
      if parent_node != ''
        tag_content = content_tag(:tr, content_tag(:td, content), {"data-tt-parent-id" => parent_node, "data-tt-id" => id} )
      else
        tag_content = content_tag(:tr, content_tag(:td, content), {"data-tt-id" => id} )
      end
      @html += tag_content
      print_tree(subtree, id, id_list) unless subtree.empty?  || subtree[:member]
    end

    @html
  end

  def edit?
    params[:action] == "edit"
  end

  def filter_user_collections(user_collections,collection)
    user_collections.reject {|a| a.noid == collection.noid}
  end

  def collection_cancel_path(collection=nil)
    path = sufia.dashboard_index_path unless edit?
    path = collections.collection_path(collection) if edit?
    path
  end

  def accession_cancel_path(accession=nil, collection=nil)
    if (edit?)
      path = accession_path(accession)
    elsif !collection.blank?
      path = collections.collection_path(collection)
    else
      path = sufia.dashboard_index_path
    end
    path
  end

  def generate_breadcrumb
    controller = params[:controller]
    action = params[:action]
    render partial: "breadcrumbs", locals:{controller:controller, action:action} if (["edit","show"].include? action) || (action == "index" && controller == "collections")
  end

end
