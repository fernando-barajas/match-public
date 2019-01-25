module Judge
  class ActivityStatusController < ApplicationController
    def create
      @activity_status = ActivityStatus.new(activity_status_params)
      @activity_status.user_id = current_user.id
      @activity_status.approve = true
      if @activity_status.save && verify_activity_general_status
        flash[:notice] = t('activities.messages.approved')
      else
        flash[:alert] = t('activities.messages.error_approving')
      end
      redirect_to judge_activity_path(@activity_status.activity_id)
    end

    def update
      change_activity_status
      if @activity_status.update_attribute(:approve, @activity_status.approve) && verify_activity_general_status
        flash[:notice] = @activity_status.approve ? t('activities.messages.approved') : t('activities.messages.unapproved')
      else
        flash[:alert] = @activity_status.approve ? t('activities.messages.error_approving') : t('activities.messages.error_unapproving')
      end
      redirect_to judge_activity_path(@activity_status.activity_id)
    end

    private

    def change_activity_status
      @activity_status = ActivityStatus.user_approve_status_activity(current_user.id, params[:activity_id])
      @activity_status.approve = !@activity_status.approve
    end

    def activity_status_params
      params.permit(:activity_id)
    end

    def verify_activity_general_status
      activity_statuses = ActivityStatus.approves_in_activity(params[:activity_id])
      activity = Activity.find(params[:activity_id])
      if activity_statuses.count == 3
        activity.update_attribute(:status, 2)
      else
        activity.update_attribute(:status, 1)
      end
    end
  end
end