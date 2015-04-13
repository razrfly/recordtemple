class Page < ActiveRecord::Base
  extend FriendlyId
  belongs_to :user
  attachment :cover

  # has_many :children, class_name: 'Page', foreign_key: :parent_id
  # belongs_to :parent, class_name: 'Page', foreign_key: :parent_id

  friendly_id :title, use: [:scoped, :finders], scope: :user

  validates_presence_of :title

  def cover_photo
    Refile.attachment_url(self, :cover, :fill, 60, 60) unless cover.blank?
  end

  # scope :active, -> { where active: true }
  # scope :roots, -> { where parent_id: nil }

  # def should_generate_new_friendly_id?
    # new_record? || slug.blank?# || title_changed?
  # end

  # def root?
    # parent_id.blank?
  # end

  # def siblings
    # parent unless parent == self
  # end

end
