# encoding: utf-8

module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      skip_before_filter :verify_authenticity_token, if: :json_request?

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        yield resource if block_given?
        return head :bad_request unless successfully_sent?(resource)
        head :no_content
      end

      # PUT /resource/password
      def update
        self.resource = resource_class.reset_password_by_token(resource_params)
        yield resource if block_given?
        errors = resource.errors

        if errors.empty?
          resource.unlock_access! if unlockable?(resource)
          head :no_content
        else
          render json: { errors: errors }, status: :bad_request
        end
      end

      protected

      def json_request?
        request.format.json?
      end
    end
  end
end
