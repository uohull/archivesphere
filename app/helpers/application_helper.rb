module ApplicationHelper
  def print_tree(node, parent_node)
    node.each_pair do |path, subtree| 
      puts "#{node.inspect}"
      id = File.basename(path)
      parent_id = path[1..-1].chomp(id)
      parent_id = parent_id[0..-2] if parent_id[-1] == "/"
      @html += "\n" 
      if parent_id != ''
        @html += content_tag(:tr, content_tag(:td, File.basename(path)), {"data-tt-parent-id" => parent_node, "data-tt-id" => id} )
      else
        @html += content_tag(:tr, content_tag(:td, File.basename(path)), {"data-tt-id" => id} )
      end
      print_tree(subtree, id) unless subtree.empty?
    end 
    @html
  end

end
