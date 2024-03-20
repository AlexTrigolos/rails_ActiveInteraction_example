class User < ApplicationRecord
  has_many :interests_users, dependent: :destroy
  has_many :interests, through: :interests_users

  has_many :skills_users, dependent: :destroy
  has_many :skills, through: :skills_users
end

class Interest < ApplicationRecord
  has_many :interests_users, dependent: :destroy
  has_many :users, through: :interests_users
end

class Skill < ApplicationRecord
  has_many :skills_users, dependent: :destroy
  has_many :users, through: :skills_users
end

class InterestsUser < ApplicationRecord
  belongs_to :interest
  belongs_to :user

  validates :user_id, uniqueness: { scope: :interest_id }
end

class SkillsUser < ApplicationRecord
  belongs_to :skill
  belongs_to :user

  validates :user_id, uniqueness: { scope: :skill_id }
end

# In application we are using ActiveInteraction gem => https://github.com/AaronLasseigne/active_interaction
module Users
  class Create < ActiveInteraction::Base
    string :name, :patronymic, :email, :nationality, :country, :gender
    integer :age

    string :surname, :fullname, :skills, default: nil
    array :interests, default: nil

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    validates :name, :patronymic, :email, :age, :nationality, :country, :gender, presence: true

    validates :age, numericality: { greater_than_or_equal_to: 0, less_than: 90 }
    validates :gender, inclusion: { in: %w[male female] }
    validates :email, length: { maximum: 105 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

    set_callback :validate, :before, -> { self.email = email.downcase }
    set_callback :create, :before, -> { self.fullname ||= [surname, name, patronymic].join(' ').squish }

    def to_model
      User.new
    end

    def execute
      user = User.includes(:interests, :skills)
                 .new(name:, patronymic:, email:, nationality:, country:, gender:, age:, surname:, fullname:)

      params['interests'].each { |name| user.interests.find_or_initialize_by(name:) }
      params['skills'].split(',').each { |name| user.skills.find_or_initialize_by(name:) }

      errors.merge!(user.errors) unless user.save

      user
    end
  end
end

# User object in database
name string
surname string
patronymic string
fullname string
email string
age integer
nationality string
country string
interests array
gender string
skills string

# Interest object in database
name string
# Skill object in database
name string
