class SignUpForm
  include ActiveModel::Model

  attr_accessor :email,
                :email_confirm,
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
end
