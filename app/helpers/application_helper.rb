module ApplicationHelper
  def print_tree(node, parent_node, id_list=[])
    node.each_pair do |path, subtree|
      id= orig_id = File.basename(path)#.tr(" ", "_")
      i=0
      while id_list.include?(id)
        i+=1
        id=orig_id+"_"+i.to_s
      end
      id_list << id
      @html += "\n"
      content =  File.basename(path)
      unless subtree[:member].blank?
      content = link_to File.basename(path),sufia.generic_file_path(subtree[:member].id)
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

end
