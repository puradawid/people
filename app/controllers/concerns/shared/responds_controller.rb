module Shared::RespondsController
  extend ActiveSupport::Concern

  included do
    private

    def respond_on_failure errors
      respond_to do |format|
        format.html { render choose_action(action_name), alert: I18n.t("messages.error",  type: action_name) }
        format.json { render json: { errors: errors }, status: 400 }
      end
    end

    def respond_on_success redirect_to_path
      respond_to do |format|
        format.html { redirect_to redirect_to_path, notice: I18n.t("messages.success", type: action_name, object_name: controller_name.titleize[0..-2]) }
        format.json { render :show }
      end
    end

    def choose_action action
      action=='create' ? :new : :edit
    end

  end

end
