module AccessionHelper

  def display_disk_image(disk_image)
    disk_image.to_s == "true" ? "Yes" : "No"
  end

  def display_file_data(document)
    file_data =[]
    if document.file_size
      file_size = document.file_size.to_i / 1000
      file_data << (file_size).to_s+"K"
    end
    file_data << document.file_type.split("/")[1] if  document.file_type
    truncate(file_data.join(", "), length:20)
  end
  def display_file_title(document)
    file_data =[]
    if document.file_size
      file_size = document.file_size.to_i / 1000
      file_data << (file_size).to_s+"K"
    end
    file_data << document.file_type if  document.file_type
    file_data.join(", ")
  end
end
