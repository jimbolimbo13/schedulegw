class Professorlist < ActiveRecord::Base

  def self.assign_prof_id(course)
    return if course.professor.nil?

    @lastname = course.professor
    @gwid = course.gwid

    # Find all that match the lastname.
    @profs = Professorlist.where(last_name: @lastname)
    if @profs.count == 1
      return @profs.first.prof_id  # If we found only one, we win.
    elsif @profs.count == 0
      return nil
    elsif @profs.count > 1
      return if course.gwid.nil?

      scores = {}
      @profs.each do |pp|
        scores[pp.id] = Course.where(gwid: @gwid, professor: pp.last_name).count
      end
      ordered = scores.sort_by {|k,v| v}.reverse # faster according to the internet.
      winner = Professor.find(ordered[0][0])
      prof_id = winner.prof_id # key of the first response [first][key]
      return prof_id
    end


  end

end
