Frab::Application.routes.draw do
  scope '(:locale)' do
    resource :session

    get '/conferences/new' => 'conferences#new', as: 'new_conference'
    post '/conferences' => 'conferences#create', as: 'create_conference'
    get '/conferences' => 'conferences#index', as: 'conference_index'
    delete '/conferences' => 'conferences#destroy'

    resources :people do
      resource :user
      member do
        put :attend
      end
    end

    scope path: '/:conference_acronym' do
      namespace :public do
        get '/schedule' => 'schedule#index', as: 'schedule'
        get '/schedule/custom' => 'schedule#custom', as: 'custom'
        get '/schedule/custom/:id' => 'schedule#custom_show', as: 'custom_show'

        resources :events do
          resource :feedback, controller: :feedback
        end
      end # namespace :public

      namespace :cfp do
        resource :session

        resource :user do
          resource :password
          resource :confirmation do
            member do
              get '/confirm_attendance' => :confirm_attendance
            end
          end
        end

        resource :person do
          resource :availability
          get :cancel_attendance
          get :confirm_attendance
          member do
            post :request_invitation, to: 'invitations#request_invitation'
          end
        end

        post '/send_invitation' => 'invitations#invite', as: 'send_invitation'

        get '/events/:id/confirm/:token' => 'events#confirm', as: 'event_confirm_by_token'
        get '/events/:id/update_state' => 'events#update_state', as: 'update_state_cfp_event_path'
        resources :events do
          member do
            put :withdraw
            put :confirm
            put :update_state
          end
        end

        get '/open_soon' => 'welcome#open_soon', as: 'open_soon'
        get '/not_existing' => 'welcome#not_existing', as: 'not_existing'

        root to: 'people#show'
        resource :dif
      end # namespace :cfp

      get '/recent_changes' => 'recent_changes#index', as: 'recent_changes'

      post '/schedule.pdf' => 'schedule#custom_pdf', as: 'schedule_custom_pdf', defaults: { format: :pdf }
      get '/schedule' => 'schedule#index', as: 'schedule'
      get '/schedule/update_track' => 'schedule#update_track', as: 'schedule_update_track'
      put '/schedule/update_event' => 'schedule#update_event', as: 'schedule_update_event'
      get '/schedule/new_pdf' => 'schedule#new_pdf', as: 'new_schedule_pdf'
      get '/schedule/html_exports' => 'schedule#html_exports'
      post '/schedule/create_static_export' => 'schedule#create_static_export'
      get '/schedule/download_static_export' => 'schedule#download_static_export'

      get '/statistics/events_by_state' => 'statistics#events_by_state', as: 'events_by_state_statistics'
      get '/statistics/language_breakdown' => 'statistics#language_breakdown', as: 'language_breakdown_statistics'
      get '/statistics/gender_breakdown' => 'statistics#gender_breakdown', as: 'gender_breakdown_statistics'

      resource :conference, except: [:new, :create] do
        get :edit_tracks
        get :edit_days
        get :edit_schedule
        get :edit_rooms
        get :edit_ticket_server
        get :edit_notifications
        post :send_notification
      end
      get '/conferences/default_notifications' => 'conferences#default_notifications', as: 'conferences_default_notifications'
      get '/statistics/all_stats' => 'statistics#all_stats', as: 'statistics_all_stats'

      resource :call_for_participation

      resources :people do
        resource :user
        resource :availability, except: %i(create show)
        resources :expenses
        resources :transport_needs
        collection do
          get :all
          get :feedbacks
          get :all_confirmed
          get :speakers
          get :volunteers
          get :dif
          get :confirmed_speakers
          get :make_fellow
          get :cancel_attendance
          get :cancel_ticket
          get :move_to_pending
          get :allow_late_submissions
          get :confirm_user
          get :confirm_attendance
          get :waitlisted
          get :invite
          get :move_to_waitlist
          get :canceled
          get :generate_confirmation_tokens
          get :tickets
        end
        member do
          post :send_invitation
          post :accept_request
          post :add_invitations
          post :on_hold_request
          post :reject
        end
      end

      scope path: '/invitations/:id' do
        get :ticketing_form, to: 'tickets#ticketing_form'
        post :register_ticket, to: 'tickets#register_ticket'
        get :view_ticket, to: 'tickets#view_ticket'
        get :send_ticket, to: 'tickets#send_ticket'
        get :cancel_ticket, to: 'tickets#cancel_ticket'
        get :refund_ticket, to: 'tickets#refund_ticket'
        patch :update_ticket_public_name, to: 'tickets#update_ticket_public_name'

        scope path: "/tickets/:ticket_id" do
          resources :charges
        end
      end

      resources :events do
        collection do
          get :my
          get :ratings
          get :feedbacks
          get :start_review
          get :cards
          get :export_accepted
          get :export_confirmed
        end
        member do
          get :people
          get :edit_people
          get :ticket
          put :update_state
          put :update_state_with_email
          post :custom_notification
          get :grant_dif
        end
        resource :event_rating
        resources :event_feedbacks
      end

      get '/reports' => 'reports#index', as: 'reports'
      get '/reports/on_people/:id' => 'reports#show_people', as: 'report_on_people'
      get '/reports/on_events/:id' => 'reports#show_events', as: 'report_on_events'
      get '/reports/on_statistics/:id' => 'reports#show_statistics', as: 'report_on_statistics'
      get "/reports/on_transport_needs/:id" => "reports#show_transport_needs", as: "report_on_transport_needs"

      resources :tickets do
        member do
          post :create
        end
      end

      resources :mail_templates do
        member do
          put :send_mail
        end
      end

      resource :invitations, only: [:new, :create]
    end # scope path: "/:conference_acronym"

    get '/:conference_acronym' => 'home#index', as: 'conference_home'
  end # scope "(:locale)" do

  root to: 'home#index'
end
