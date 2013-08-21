module AccessionHelper

  def display_disk_image(disk_image)
    disk_image.to_s == "true" ? "Yes" : "No"
  end

end
