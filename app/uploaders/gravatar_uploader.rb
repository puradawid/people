class GravatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file
  process resize_to_fit: [100, 100]

  version :thumb do
    process resize_to_fit: [40, 40]
  end

  version :circle do
    process resize_to_fit: [30, 30]
  end

  def store_dir
    "uploads/gravatars/#{email_md5}"
  end

  def extension_white_list
    %w(jpg jpeg)
  end

  private

  def email_md5
    Digest::MD5.hexdigest(model.email)
  end
end
