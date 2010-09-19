# encoding: utf-8

class MiniMagick::MiniMagickError < RuntimeError; end

class AttachmentUploader < CarrierWave::Uploader::Base
  
  # Include RMagick or ImageScience support
  #include CarrierWave::RMagick
  #     include CarrierWave::ImageScience
  include CarrierWave::MiniMagick
  # Choose what kind of storage to use for this uploader
  storage :file
  #     storage :s3

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "../uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :scale => [64, 64]
  end

  def scale(width, height)
    begin
      resize_to_fill(64, 64)
      convert("png")
    rescue MiniMagick::Invalid => e

    end
  end
  # Process files as they are uploaded.
  #     process :scale => [200, 300]
  #
  #     def scale(width, height)
  #       # do something
  #     end

  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  #     def extension_white_list
  #       %w(jpg jpeg gif png)
  #     end

  # Override the filename of the uploaded files
  #     def filename
  #       "something.jpg" if original_filename
  #     end

end
