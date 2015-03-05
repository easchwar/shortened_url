# == Schema Information
#
# Table name: taggings
#
#  id     :integer          not null, primary key
#  tag_id :integer          not null
#  url_id :integer          not null
#

class Tagging < ActiveRecord::Base

  belongs_to(
    :tag,
    class_name: :TagTopic,
    foreign_key: :tag_id,
    primary_key: :id
  )

  belongs_to(
    :url,
    class_name: :ShortenedUrl,
    foreign_key: :url_id,
    primary_key: :id
  )
end
