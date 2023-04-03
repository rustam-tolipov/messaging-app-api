class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave

  process scale: [250, 250]

end
