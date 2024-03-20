class User < ApplicationRecord
  has_many :interests_users, dependent: :destroy
  has_many :interests, through: :interests_users

  has_many :skills_users, dependent: :destroy
  has_many :skills, through: :skills_users
end

class Interest < ApplicationRecord
  has_many :interests_users, dependent: :destroy
  has_many :interests, through: :interests_users
end

class Skill < ApplicationRecord
  has_many :skills_users, dependent: :destroy
  has_many :skills, through: :skills_users
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
    hash :params do
      string :name
      string :surname, default: nil
      string :patronymic
      string :fullname, default: nil
      string :email
      integer :age
      string :nationality
      string :country
      string :gender
      array :interests, default: nil
      string :skills, default: nil
    end

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    validates :name, :patronymic, :email, :age, :nationality, :country, :gender, presence: true

    validates :age, numericality: { greater_than_or_equal_to: 0, less_than: 90 }
    validates :gender, inclusion: { in: %w[male female] }
    validates :email, length: { maximum: 105 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

    set_callback :validate, :before, -> { self.email = email.downcase }
    set_callback :create, :before, -> { self.fullname ||= [surname, name, patronymic].join(' ').squish }

    def execute
      define_interests_and_skills
      user = User.new(params)

      errors.merge!(user.errors) unless user.save

      user
    end

    private

    def define_interests_and_skills
      params[:interests] = Interest.where(name: params[:interests]) if params[:interests].present?
      params[:skills] = Skill.where(name: params[:skills].split(',')) if params[:skills].present?
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
