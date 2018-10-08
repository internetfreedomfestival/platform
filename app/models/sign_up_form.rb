class CustomValidator < ActiveModel::Validator
  def validate(form)
    selected_values = form.professional_background.reject{|value| value.blank?}
    if selected_values.length == 0
      form.errors[:professional_background] << "can't be blank"
    end
    if form.password.length < 8
      form.errors[:password] << "Your password must contain a minimum of 8 characters."
    end
    if form.password != form.password_confirmation
      form.errors[:password_confirmation] << "The password and confirmation must be the same"
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
                :email_confirmation,
                :password,
                :password_confirmation,
                :first_name,
                :gender,
                :country_of_origin,
                :include_in_mailings,
                :invitation_to_mattermost

  validates_with CustomValidator, fields: [:professional_background]
  validates_with CustomValidator, fields: [:password]
  validates_with CustomValidator, fields: [:password_confirmation]
end
