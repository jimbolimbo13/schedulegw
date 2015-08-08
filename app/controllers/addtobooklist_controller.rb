class AddtobooklistController < ApplicationController
  def index

  end

  def new
    @booklistsuggestion = Booklistsuggestion.new
  end

  def update
    @suggestion = Booklistsuggestion.create(booklistsuggestion_params)
    @suggestion.isbn = @suggestion.isbn.gsub(/\D/, '')
    @suggestion.user = current_user if current_user

    if @suggestion.save!
      respond_to do |format|
        flash[:notice] = current_user ? "Suggestion received, thanks #{current_user.name}" : "Suggestion received!"
        format.html {redirect_to addtobooklist_new_path }
      end
    end

  end

  def get_course
    # AJAX CALLS HIT THIS
    @gwid = params[:gwid] ||= nil
    @section = params[:section] ||= nil
    @crn = params[:crn] ||= nil

    # If no course found from the crn
    @course_1 = Course.where("gwid = ? AND section = ?", @gwid.to_s, @section.to_s) if (@gwid && @section)

    # Check to see if crn finds anything
    @course_2 = Course.find_by(crn: @crn) if @crn

    # If both exist
    @course = @course_1 ||= @course_2

    respond_to do |format|
      if @course != nil && @course != []
       format.json { render json: @course }
      else
       format.json { render json: {} }
      end
    end
  end

  def accept_suggestion
    if current_user.admin?
      @suggestion = Booklistsuggestion.find(params[:suggestion_id])
      if @suggestion.accept_suggestion
        respond_to do |format|
          flash[:notice] = "Suggestion Accepted"
          format.html { redirect_to courses_url }
          format.json { head :no_content }
        end
      end
    end
  end

  def destroy
    if current_user.admin?
      @suggestion = Booklistsuggestion.find(params[:suggestion_id])
      if @suggestion.destroy!
        respond_to do |format|
          flash[:notice] = "Suggestion Deleted"
          format.html { redirect_to courses_url }
          format.json { head :no_content }
        end
      end
    end
  end

  private

    def booklistsuggestion_params
      params.require(:booklistsuggestion).permit(	:crn,
                    :gwid,
                    :section,
                    :isbn
                    )
    end



end
