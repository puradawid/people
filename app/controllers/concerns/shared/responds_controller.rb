module Shared::RespondsController
  extend ActiveSupport::Concern

  included do
    private

    def respond_on_failure errors
      respond_to do |format|
        format.html { render :new, alert: I18n.t("#{controller_name}.error",  type: action_name) }
        format.json { render json: { errors: errors }, status: 400 }
      end
    end

    def respond_on_success redirect_to_path
      respond_to do |format|
        format.html { redirect_to redirect_to_path, notice: I18n.t("#{controller_name}.success", type: action_name) }
        format.json { render :show }
      end
    end

  end

end
