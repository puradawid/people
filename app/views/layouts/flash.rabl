node(:notice) { @flashMessage[:notice] } if @flashMessage[:notice].any?
node(:alert) { @flashMessage[:alert] } if @flashMessage[:alert].any?
