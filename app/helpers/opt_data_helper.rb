module OptDataHelper
  def self.find_cheap_solution(rooms, guests)
    problem = generate_problem_name

    File.open("smartfilter/tasks/#{problem}.dat", 'w') do |data|
      write_rooms_set(rooms, data)
      write_base_params(rooms, guests, data)
      write_capacity_and_stars_and_price_params(rooms, data)
    end

    run_solver_on(problem, PROPERTIES['smartfilter-models']['cheap'], rooms)
  end

  def find_cheap_solution(rooms, guests)
    self.find_cheap_solution(rooms, guests) #return
  end


  def self.find_close_solution(rooms, distances, guests)
    problem = generate_problem_name

    File.open("smartfilter/tasks/#{problem}.dat", 'w') do |data|
      write_rooms_set(rooms, data)
      write_base_params(rooms, guests, data)
      write_capacity_and_stars_params(rooms, data)
      write_distance_params(rooms, distances, data)
    end

    run_solver_on(problem, PROPERTIES['smartfilter-models']['close'], rooms)
  end

  def find_close_solution(rooms, distances, guests)
    self.find_close_solution(rooms, distances, guests) #return
  end


  def self.find_cheap_and_close_solution(rooms, distances, guests)
    problem = generate_problem_name

    File.open("smartfilter/tasks/#{problem}.dat", 'w') do |data|
      write_rooms_set(rooms, data)
      write_base_params(rooms, guests, data)
      write_capacity_and_stars_and_price_params(rooms, data)
      write_distance_params(rooms, distances, data)
    end

    run_solver_on(problem, PROPERTIES['smartfilter-models']['cheap_and_close'], rooms)
  end

  def find_cheap_and_close_solution(rooms, distances, guests)
     self.find_cheap_and_close_solution(rooms, distances, guests) #return
  end


  def self.run_solver_on(problem, model, rooms)
    write_solver_script(problem, model)

    tstart = Time.now

    command = "ampl smartfilter/tasks/#{problem}.solve > smartfilter/tasks/#{problem}.solution"
    has_run = system(command)

    tend = Time.now

    puts "EXECUTION TIME: #{(tend-tstart)*1000.0}"

    if has_run
      until system("ls smartfilter/tasks/#{problem}.solution") do
        sleep(0.05)
      end

      lines = `cat smartfilter/tasks/#{problem}.solution | wc -l`
      if lines.to_i <= rooms.size+3
        puts 'NOT FEASIBLE'
        return Array.new
      else
        system("cat smartfilter/tasks/#{problem}.solution | tail -n#{rooms.size+4} | head -n#{rooms.size+2} > smartfilter/tasks/#{problem}.raw_solution")
        OptSolutionHelper.read_solution_for(problem, rooms)
      end
    end
  end


  def self.generate_problem_name
    return "#{DateTime.now}_VSF#{rand(100)}#{rand(100)}"
  end


  def self.write_solver_script(problem, model)
    File.open("smartfilter/tasks/#{problem}.solve", 'w') do |s|
      s.write("option solver bonmin;\n")
      s.write("options bonmin_options \"bonmin.algorithm B-OA\";\n")
      s.write(Property.find_by_key(model).value.to_s)
      s.write("\ndata smartfilter/tasks/#{problem}.dat;\n")
      s.write("solve;\n")
      s.write("option display_1col 1000000;\n")
      s.write('display Occupation;')
    end
  end


  def self.write_rooms_set(rooms, data)
    data.write('set ROOMS:= ')
    rooms.each_key do |room_key|
      data.write("#{room_key} ")
    end
    data.write(";\n")
  end


  def self.write_base_params(rooms, guests, data)
    min_capacity = Float::INFINITY
    rooms.each_value do |room|
      min_capacity = room.capacity if room.capacity < min_capacity
    end
    data.write("param min_capacity := #{min_capacity};\n")
    data.write("param guests := #{guests};\n")
  end


  def self.write_capacity_and_stars_params(rooms, data)
    data.write("param:\tcapacity\tstars :=\n")
    rooms.each_pair do |key, room|
      data.write("\t\t#{key}\t#{room.capacity}\t#{CommentHelper.get_average_stars_for(room)*10}\n")
    end
    data.write(";\n")
  end


  def self.write_capacity_and_stars_and_price_params(rooms, data)
    price_categories = self.build_price_categories(rooms)

    data.write("param:\tcapacity\tstars\tprice :=\n")
    rooms.each_pair do |key, room|
      price_category = price_categories[room.price.value_with_vat]
      data.write("\t\t#{key}\t#{room.capacity}\t#{CommentHelper.get_average_stars_for(room)*10}\t#{price_category}\n")
    end
    data.write(";\n")
  end


  def self.write_distance_params(rooms, distances, data)
    distance_categories = self.build_distance_categories(distances)

    data.write("param\tdistance: ")
    rooms.each_key do |key|
      data.write("#{key} ")
    end
    data.write(":=\n")
    i = 0
    rooms.each_key do |key|
      data.write("\t\t#{key}\t")
      j = 0
      rooms.each_value do |moor|
        distance_category = distance_categories[distances[i][j]]
        data.write("#{distance_category}\t")
        j += 1
      end
      data.write("\n")
      i += 1
    end
    data.write(";\n")
  end

  def self.build_price_categories(rooms)
    price_categories = Hash.new

    min_price = Float::INFINITY

    rooms.each_value do |room|
      price = room.price.value_with_vat
      unless price_categories.has_key? price
        price_categories[price] = 0

        min_price = price if price < min_price
      end
    end

    price_categories.keys.sort.each do |price|
      price_categories[price] = price/min_price
    end

    puts price_categories.to_s
    return price_categories
  end

  def self.build_distance_categories(distances)
    distances.each_index do |i|
      distances[i].each_index do |j|
        distances[i][j] += 1
      end
    end

    distance_categories = Hash.new

    min_distance = Float::INFINITY

    distances.each do |sub_distances|
      sub_distances.each do |distance|
        unless distance_categories.has_key? distance
          distance_categories[distance] = 0

          if distance < min_distance
            min_distance = distance
          end
        end
      end
    end

    distance_categories.keys.sort.each do |distance|
      distance_categories[distance] = distance/min_distance
    end

    return distance_categories
  end
end