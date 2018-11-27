# frozen_string_literal: true
class InvitesAssignation < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
end
