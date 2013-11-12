module AccessionHelper

  def display_disk_image(disk_image)
    disk_image.to_s == "true" ? "Yes" : "No"
  end

  def display_file_data(document)
    file_data =[]
    if document.file_size
      file_data << display_file_size(document.file_size)
    end
    file_data << document.file_type.split("/")[1] if  document.file_type
    truncate(file_data.join(", "), length:20)
  end
  def display_file_title(document)
    file_data =[]
    if document.file_size
      file_data << display_file_size(document.file_size)
    end
    file_data << document.file_type if  document.file_type
    file_data.join(", ")
  end

  def display_file_size(file_size)
    return nil unless file_size
    file_size = file_size.to_i
    number_to_human_size(file_size)
  end
end
