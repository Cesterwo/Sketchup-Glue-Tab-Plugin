require 'sketchup.rb'

class GlueTab
	def initialize
		@tab_width = 1.0
	end
	
	def onLButtonDown(flags, x, y, view)
		model = Sketchup.active_model
		ph = model.active_view.pick_helper
		ph.do_pick x, y
		
		if edge = ph.picked_edge
			faces = edge.faces
			if faces.length == 1
				draw_tab(model, edge, faces.first)
			end
		end
	end
	
	def draw_tab(model, edge, face)
		normal_vector = face.normal
		line = edge.line
		
		# Calculate a unit vector perpendicular to the edge
		v = normal_vector * line[1]
		
		tab_points = calculate_tab_points(edge.start.position, edge.end.position, v, line[1])
		
		# Sometimes the vectors will get reversed, and the tab will be positioned on the face.
		# If that's the case, reverse the magic vector to make the tab is point away from the face
		# I hate having to recalculate the whole thing, but it's the best solution I could come up with
		unless (face.classify_point(tab_points[2]) == 8) && (face.classify_point(tab_points[3]) == 8)
			tab_points = calculate_tab_points(edge.start.position, edge.end.position, v.reverse, line[1])
		end
		
		
		model.entities.add_face tab_points
	end
	
	def calculate_tab_points(edge_start_position, edge_end_position, magic_unit_vector, line_vector)
		# The magic unit vector is perpendicular to the edge and the normal vector of the face
		
		tab_width_vector = magic_unit_vector.clone
		tab_width_vector.length = @tab_width
		
		trapezoid_end_vector = line_vector.clone
		trapezoid_end_vector.length = @tab_width
		
		pt1 = edge_start_position
		pt2 = edge_end_position
		pt3 = edge_end_position   + tab_width_vector - trapezoid_end_vector
		pt4 = edge_start_position + tab_width_vector + trapezoid_end_vector
		[pt1, pt2, pt3, pt4]
	end
end

menu_name = "Glue Tab"
UI.menu("Plugins").add_item(menu_name) {
	Sketchup.active_model.select_tool GlueTab.new
} 