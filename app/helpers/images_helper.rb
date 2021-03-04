module ImagesHelper
  def img_url_or_default(url)
    url.nil? ? image_path('ga_placeholder_img.png') : url
  end
end
