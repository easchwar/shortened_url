# == Schema Information
#
# Table name: shortened_urls
#
#  id           :integer          not null, primary key
#  long_url     :string           not null
#  short_url    :string           not null
#  submitter_id :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#

class ShortenedUrl < ActiveRecord::Base
  validates :long_url, presence: true
  validates :long_url, length: { maximum: 1024 }
  validates :short_url, presence: true
  validates :submitter_id, presence: true
  validate :number_of_urls_submitted_in_last_minute_by_same_user

  belongs_to(
    :submitter,
    class_name: :User,
    foreign_key: :submitter_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: :Visit,
    foreign_key: :url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :user
  )

  has_many(
    :taggings,
    class_name: :Tagging,
    foreign_key: :url_id,
    primary_key: :id
  )

  has_many(
    :tags,
    through: :taggings,
    source: :tag
  )

  def self.random_code
    rand_string = SecureRandom.urlsafe_base64
    while self.exists?(short_url: rand_string)
      rand_string = SecureRandom.urlsafe_base64
    end
    rand_string
  end

  def self.create_for_user_and_long_url!(user, long_url)
    create!(submitter_id: user.id, long_url: long_url, short_url: random_code)
  end

  def num_clicks
    visits.length
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques(time_period)
    visits.where("created_at > ?", time_period).select(:user_id).distinct.count
  end

  private
  def number_of_urls_submitted_in_last_minute_by_same_user
    count = ShortenedUrl.all.where("created_at > ? AND submitter_id = ?", 5.minutes.ago, submitter_id).count
    errors[:base] << "too many submissions by user within last 5 minutes" if count > 5
  end
end
