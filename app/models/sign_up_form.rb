class CustomValidator < ActiveModel::Validator
  def validate(form)
    if form.professional_background.blank?
      form.errors[:professional_background] << "can't be blank"
    end
    if form.email.present?
      if Person.find_by(email: form.email)
        form.errors[:email] << "This email already exist"
      end
    end
  end
end
class SignUpForm
  include ActiveModel::Model

  attr_accessor :email,
                :email_confirmation,
                :password,
                :password_confirmation,
                :first_name,
                :last_name,
                :pgp_key,
                :gender,
                :country_of_origin,
                :group,
                :professional_background,
                :other_background,
                :organization,
                :project,
                :include_in_mailings,
                :invitation_to_mattermost

  validates_presence_of :email,
                :password,
                :first_name,
                :gender,
                :country_of_origin,
                :include_in_mailings,
                :invitation_to_mattermost

  validates_confirmation_of :email,
                :password

  validates_length_of :password, minimum: 8

  validates_with CustomValidator, fields: [:professional_background]
  validates_with CustomValidator, fields: [:email]
end
