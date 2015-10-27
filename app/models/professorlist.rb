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

      scores = {}
      @profs.each do |contender|
        scores[contender.id] = Course.where(gwid: course.gwid, professor: @lastname).count
      end

      ordered = scores.sort.reverse
      winner = Professorlist.find(ordered.first[0])
      return winner.prof_id

    end


  end

end
