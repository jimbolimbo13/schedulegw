class Professorlist < ActiveRecord::Base

  def self.assign_prof_id(course)
    return if course.professor.nil?
    return if course.gwid.nil?

    @lastname = course.professor
    @gwid = course.gwid

    # Find all that match the lastname.
    @profs = Professorlist.where(last_name: @lastname)
    return @profs.first.prof_id if @profs.count == 1 # If we found only one, we win.

    scores = {}
    @profs.each do |possible_prof|
      scores[possible_prof.id] = Professorlist.where(gwid: @gwid).count
    end
    ordered = scores.sort_by {|k,v| v}.reverse # faster according to the internet.
    prof_id = ordered[0][0] # key of the first response [first][key]
    return prof_id

  end

end
